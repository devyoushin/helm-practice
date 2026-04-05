# Helm 실전 팁 가이드

실제 운영 환경에서 Helm을 사용할 때 알아두면 유용한 팁과 패턴을 정리합니다.

---

## 1. 환경별 values 파일 분리 전략

### 파일 구조
```
charts/production-app/
├── values.yaml           # 기본값 (공통)
├── values-dev.yaml       # dev 오버라이드
├── values-staging.yaml   # staging 오버라이드
└── values-prod.yaml      # prod 오버라이드
```

### 사용법
```bash
# 기본값 + 환경 오버라이드 합성 (오른쪽이 우선순위 높음)
helm install my-app charts/production-app \
  -f charts/production-app/values-prod.yaml \
  --set secret.data.DB_PASSWORD=$DB_PASSWORD

# 현재 적용된 values 확인
helm get values my-app -n production
```

> **팁**: `-f` 여러 개 중첩 가능. 오른쪽 파일이 왼쪽 파일을 덮어씁니다.
> ```bash
> helm upgrade my-app charts/production-app \
>   -f values-base.yaml \
>   -f values-prod.yaml \
>   -f values-hotfix.yaml   # 가장 높은 우선순위
> ```

---

## 2. 배포 전 필수 검증 루틴

```bash
# 1단계: 문법 검사
helm lint charts/production-app

# 2단계: 렌더링 결과 미리보기 (클러스터 불필요)
helm template my-app charts/production-app -f values-prod.yaml

# 3단계: 실제 클러스터에 dry-run (API 검증 포함)
helm install my-app charts/production-app \
  -f values-prod.yaml \
  --dry-run --debug \
  -n production

# 4단계: diff 플러그인으로 변경사항만 확인 (upgrade 전 필수)
helm plugin install https://github.com/databus23/helm-diff
helm diff upgrade my-app charts/production-app -f values-prod.yaml -n production
```

> **팁**: CI/CD 파이프라인에 `helm lint` + `helm template` + `helm diff`를 반드시 포함시키세요.
> 운영 장애의 상당수는 diff 확인만 해도 사전 방지가 됩니다.

---

## 3. Secret 안전하게 관리하기

### 방법 1: --set으로 주입 (CI/CD 환경변수 활용)
```bash
helm upgrade my-app charts/production-app \
  -f values-prod.yaml \
  --set secret.data.DB_PASSWORD=$DB_PASSWORD \
  --set secret.data.API_KEY=$API_KEY \
  -n production
```

### 방법 2: helm-secrets 플러그인 (SOPS + KMS 암호화)
```bash
helm plugin install https://github.com/jkroepke/helm-secrets
# secrets.prod.yaml을 암호화된 상태로 저장 후:
helm secrets upgrade my-app charts/production-app \
  -f values-prod.yaml \
  -f secrets://secrets.prod.yaml \
  -n production
```

### 방법 3: External Secrets Operator (권장 — 운영 수준)
```yaml
# ExternalSecret 리소스 → AWS SSM/Secrets Manager에서 자동으로 K8s Secret 생성
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: my-app-secret
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: aws-ssm
  target:
    name: production-app-secret
  data:
    - secretKey: DB_PASSWORD
      remoteRef:
        key: /production/my-app/db-password
```

> **주의**: `values.yaml`에 평문 Secret을 절대 커밋하지 마세요.
> `.gitignore`에 `secrets*.yaml`, `*-secret.yaml` 추가 필수.

---

## 4. ConfigMap/Secret 변경 시 Pod 자동 재시작

기본적으로 ConfigMap을 변경해도 Pod는 재시작되지 않습니다.
`checksum` 어노테이션 패턴으로 이를 해결합니다.

```yaml
# templates/deployment.yaml
template:
  metadata:
    annotations:
      checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
      checksum/secret: {{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}
```

ConfigMap 내용이 바뀌면 checksum이 변경되고 → Pod가 자동 재시작됩니다.

---

## 5. 무중단 배포 (Zero-downtime Deploy)

```yaml
# values.yaml
updateStrategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1        # 추가로 생성할 수 있는 Pod 수
    maxUnavailable: 0  # 동시에 내릴 수 있는 Pod 수 (0 = 무중단)

# Readiness Probe 필수! 새 Pod가 준비되기 전에 트래픽을 받지 않도록
readinessProbe:
  enabled: true
  httpGet:
    path: /ready
    port: http
  initialDelaySeconds: 5
  periodSeconds: 10

# graceful shutdown — 처리 중인 요청이 끝날 때까지 대기
terminationGracePeriodSeconds: 60
```

> **팁**: `maxUnavailable: 0` + Readiness Probe 조합이 무중단 배포의 핵심입니다.
> `terminationGracePeriodSeconds`는 앱의 최대 요청 처리 시간보다 길게 설정하세요.

---

## 6. HPA와 replicaCount 충돌 방지

HPA를 활성화하면 replicaCount 필드를 Deployment에서 제거해야 합니다.
그렇지 않으면 helm upgrade 마다 HPA가 관리하는 replica 수를 덮어씁니다.

```yaml
# templates/deployment.yaml
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
```

---

## 7. Release 이름 전략

```bash
# 환경을 Release 이름에 포함시키면 동일 클러스터에서 관리가 쉬움
helm install production-app-dev    charts/production-app -f values-dev.yaml    -n dev
helm install production-app-staging charts/production-app -f values-staging.yaml -n staging
helm install production-app         charts/production-app -f values-prod.yaml   -n production

# 전체 Release 목록 한눈에 보기
helm list -A
```

---

## 8. 롤백 전략

```bash
# 배포 히스토리 확인
helm history my-app -n production

# 특정 revision으로 롤백
helm rollback my-app 3 -n production

# 바로 이전 버전으로 롤백
helm rollback my-app -n production

# 롤백도 새로운 revision을 생성함 (이력이 쌓임)
helm history my-app -n production
```

> **팁**: Argo CD / Flux 같은 GitOps 도구를 사용한다면 git revert로 롤백하는 것이 이력 추적에 더 좋습니다.

---

## 9. 디버깅 명령어 모음

```bash
# 렌더링된 매니페스트 전체 출력
helm template my-app charts/production-app -f values-prod.yaml

# 특정 템플릿 파일만 출력
helm template my-app charts/production-app -s templates/deployment.yaml

# 현재 클러스터에 배포된 매니페스트 확인
helm get manifest my-app -n production

# values 확인 (사용자가 지정한 값만)
helm get values my-app -n production

# values 확인 (기본값 포함 전체)
helm get values my-app -n production --all

# verbose 로그 (--debug)
helm upgrade my-app charts/production-app --debug -f values-prod.yaml -n production

# 특정 리소스가 왜 업데이트됐는지 추적
kubectl rollout history deployment/my-app -n production
kubectl rollout history deployment/my-app --revision=3 -n production
```

---

## 10. Chart 버전 관리 전략

```yaml
# Chart.yaml
version: 1.2.3      # Chart 버전 (템플릿/구조 변경 시 올림)
appVersion: "2.0.0" # 앱 이미지 버전 (이미지 태그 변경 시 올림)
```

| 변경 유형 | version 변경 |
|-----------|-------------|
| 템플릿 버그 픽스 | Patch (1.2.3 → 1.2.4) |
| 새 values 필드 추가 (하위 호환) | Minor (1.2.3 → 1.3.0) |
| 기존 values 구조 변경 (Breaking) | Major (1.2.3 → 2.0.0) |
| 앱 이미지만 변경 | appVersion만 변경 |

---

## 11. helm test — 배포 후 검증 자동화

```yaml
# templates/tests/test-connection.yaml
apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "production-app.fullname" . }}-test"
  annotations:
    "helm.sh/hook": test
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  restartPolicy: Never
  containers:
    - name: test
      image: curlimages/curl:latest
      command: ['curl', '-f', 'http://{{ include "production-app.fullname" . }}:{{ .Values.service.port }}/healthz']
```

```bash
# 배포 후 테스트 실행
helm test my-app -n production

# CI/CD 파이프라인에서 활용
helm upgrade --install my-app charts/production-app -f values-prod.yaml -n production
helm test my-app -n production --timeout 5m
```

---

## 12. OCI Registry로 Chart 배포 (Helm 3.8+)

```bash
# ECR에 Chart 푸시
aws ecr create-repository --repository-name helm-charts/production-app
helm package charts/production-app
helm push production-app-0.1.0.tgz oci://123456789.dkr.ecr.ap-northeast-2.amazonaws.com/helm-charts

# OCI Registry에서 설치
helm install my-app \
  oci://123456789.dkr.ecr.ap-northeast-2.amazonaws.com/helm-charts/production-app \
  --version 0.1.0 \
  -f values-prod.yaml
```

---

## 13. ArgoCD / Flux 연동 시 주의사항

```yaml
# ArgoCD Application 예시
spec:
  source:
    repoURL: https://github.com/devyoushin/helm-practice
    targetRevision: HEAD
    path: charts/production-app
    helm:
      valueFiles:
        - values-prod.yaml
      # Secret은 ArgoCD Vault Plugin 또는 ESO로 관리
```

> **주의**: ArgoCD를 사용할 때 `helm upgrade`를 직접 실행하면 ArgoCD가 OutOfSync로 감지합니다.
> GitOps 환경에서는 git push → ArgoCD sync 흐름을 유지하세요.

---

## 14. 자주 하는 실수 Top 5

| 실수 | 증상 | 해결 |
|------|------|------|
| Readiness Probe 없이 배포 | 앱 기동 중에 트래픽 들어와서 에러 | Probe 반드시 설정 |
| Secret을 values.yaml에 평문 커밋 | 보안 사고 | secrets.yaml 분리 + .gitignore |
| HPA + 고정 replicaCount | 매 upgrade마다 replica 초기화 | HPA 활성화 시 replicas 필드 제거 |
| ConfigMap 변경 후 Pod 미재시작 | 설정이 반영 안 됨 | checksum 어노테이션 패턴 사용 |
| `--set`으로 복잡한 구조 주입 | 이스케이프 오류, 가독성 저하 | `-f` 파일 방식 사용 |

---

## 15. 유용한 플러그인 목록

```bash
# 변경사항 미리보기 (upgrade 전 필수)
helm plugin install https://github.com/databus23/helm-diff

# Secret 암호화 관리
helm plugin install https://github.com/jkroepke/helm-secrets

# 여러 환경에 동시 배포
helm plugin install https://github.com/karuppiah7890/helm-schema-gen

# values.yaml JSON Schema 자동 생성 (values 유효성 검사)
helm plugin install https://github.com/losisin/helm-values-schema-json
```
