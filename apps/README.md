# 애플리케이션 차트 관리 전략

실무에서 여러 서비스의 Helm 차트를 관리하는 전략과 예제입니다.

---

## 디렉토리 구조

```
apps/
├── README.md                      # 이 파일
├── helmfile.yaml                  # 전체 앱 오케스트레이션
│
├── base/                          # 공통 Library Chart (재사용 가능한 템플릿)
│   ├── Chart.yaml
│   └── templates/
│       ├── _deployment.yaml
│       ├── _service.yaml
│       ├── _hpa.yaml
│       └── _pdb.yaml
│
├── services/                      # 서비스별 Helm 차트
│   ├── api-server/                # REST API 서버
│   │   ├── Chart.yaml
│   │   ├── values.yaml            # 공통 base values
│   │   ├── values-dev.yaml
│   │   ├── values-staging.yaml
│   │   └── values-prod.yaml
│   ├── worker/                    # 비동기 워커
│   └── frontend/                 # 프론트엔드 (Nginx)
│
└── environments/                  # 환경별 공통 값
    ├── dev.yaml
    ├── staging.yaml
    └── prod.yaml
```

---

## 핵심 전략

### 1. 하나의 차트, 여러 환경 values

차트 코드는 하나, values만 환경별로 분리합니다.

```
values.yaml          ← 모든 환경 공통 (기본값, 구조 정의)
values-dev.yaml      ← dev 오버라이드
values-staging.yaml  ← staging 오버라이드
values-prod.yaml     ← prod 오버라이드 (리소스↑, 레플리카↑, HPA 활성화)
```

적용 순서: `values.yaml` → `values-{env}.yaml` (뒤가 앞을 덮어씀)

```bash
helm upgrade my-api ./services/api-server \
  -f services/api-server/values.yaml \
  -f services/api-server/values-prod.yaml \
  --set image.tag=v1.2.3
```

### 2. image.tag는 values에 쓰지 않는다

CI/CD 파이프라인에서 `--set image.tag=$(git rev-parse --short HEAD)`로 주입합니다.
values 파일에 태그를 커밋하면 불필요한 git 변경이 생깁니다.

```yaml
# values.yaml
image:
  repository: 123456789.dkr.ecr.ap-northeast-2.amazonaws.com/api-server
  tag: ""       # CI에서 --set으로 주입
  pullPolicy: IfNotPresent
```

### 3. 시크릿은 values에 절대 넣지 않는다

- **External Secrets Operator** 사용 권장 (AWS Secrets Manager / SSM Parameter Store 연동)
- 또는 **Sealed Secrets** (암호화된 시크릿을 git에 커밋)
- Helm values의 민감 정보는 `--set-string`으로 CI에서 주입

### 4. 환경별 공통값 분리

모든 서비스에 공통으로 적용되는 환경 설정은 `environments/` 에서 관리합니다.

```yaml
# environments/prod.yaml
clusterName: prod-cluster
domain: example.com
ingressClass: nginx
certIssuer: letsencrypt-prod
```

### 5. Library Chart로 보일러플레이트 제거

여러 서비스가 동일한 Deployment/Service 구조를 쓴다면 Library Chart로 공통화합니다.
`base/` 차트가 그 역할을 합니다.

---

## CI/CD 배포 플로우

```
1. PR 머지 → 이미지 빌드 & ECR 푸시
2. image tag = git commit SHA (7자리)
3. helmfile diff -e prod (변경사항 Slack 알림)
4. helmfile -e prod sync --selector app=api-server
   --set image.tag=<SHA>
5. helm history <release> 로 배포 이력 확인
6. 이상 감지 시 helm rollback
```

---

## 배포 명령어 빠른 참조

```bash
# 렌더링 확인
helm template api-server ./services/api-server \
  -f services/api-server/values.yaml \
  -f services/api-server/values-prod.yaml \
  --set image.tag=abc1234

# 변경사항 미리 보기
helm diff upgrade api-server ./services/api-server \
  -f services/api-server/values.yaml \
  -f services/api-server/values-prod.yaml \
  --set image.tag=abc1234

# 배포
helm upgrade api-server ./services/api-server \
  --install --atomic --timeout 5m \
  --namespace production \
  -f services/api-server/values.yaml \
  -f services/api-server/values-prod.yaml \
  --set image.tag=abc1234

# 롤백
helm rollback api-server 0   # 0 = 이전 리비전
```
