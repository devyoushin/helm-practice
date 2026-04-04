# 첫 번째 Helm Chart 만들기 실습

## 목표
nginx를 배포하는 커스텀 Helm Chart를 처음부터 만들고,
values 변경 → upgrade → rollback까지 전체 흐름을 실습합니다.

---

## 디렉토리 구조

```
helm-practice/
├── charts/
│   └── my-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── _helpers.tpl
│           ├── deployment.yaml
│           ├── service.yaml
│           └── ingress.yaml
└── first-chart-practice.md
```

---

## Step 1: Chart 골격 생성

```bash
# helm create로 기본 골격 생성
helm create charts/my-app

# 또는 직접 이 repo의 charts/my-app 사용
ls charts/my-app
```

---

## Step 2: 문법 검사 및 렌더링 확인

```bash
# 문법 검사
helm lint charts/my-app

# 렌더링 결과 미리 보기 (클러스터 불필요)
helm template my-release charts/my-app

# 특정 값 덮어써서 렌더링
helm template my-release charts/my-app --set replicaCount=3 --set image.tag=1.25.0
```

---

## Step 3: 설치 (Install)

```bash
# 네임스페이스 생성
kubectl create namespace helm-demo

# dry-run으로 사전 확인
helm install my-release charts/my-app -n helm-demo --dry-run --debug

# 실제 설치
helm install my-release charts/my-app -n helm-demo

# 설치 확인
helm list -n helm-demo
kubectl get pods -n helm-demo
kubectl get svc -n helm-demo
```

예상 출력:
```
NAME        NAMESPACE   REVISION   STATUS     CHART           APP VERSION
my-release  helm-demo   1          deployed   my-app-0.1.0    1.21.0
```

---

## Step 4: 접속 테스트

```bash
# port-forward로 로컬 접속
kubectl port-forward svc/my-release-my-app 8080:80 -n helm-demo

# 다른 터미널에서
curl http://localhost:8080
# → nginx 기본 페이지 응답 확인
```

---

## Step 5: Values 확인

```bash
# 현재 적용된 values 확인
helm get values my-release -n helm-demo

# 전체 values (기본값 포함)
helm get values my-release -n helm-demo --all
```

---

## Step 6: Upgrade — 이미지 버전 변경

```bash
# image tag를 1.25.0으로 변경
helm upgrade my-release charts/my-app -n helm-demo --set image.tag=1.25.0

# revision이 2로 증가했는지 확인
helm history my-release -n helm-demo

# Pod이 새 이미지로 재시작됐는지 확인
kubectl get pods -n helm-demo -w
```

---

## Step 7: Upgrade — replicas 증가

```bash
# 파일로 값 변경
cat <<EOF > /tmp/custom-values.yaml
replicaCount: 3
image:
  tag: "1.25.0"
EOF

helm upgrade my-release charts/my-app -n helm-demo -f /tmp/custom-values.yaml

# Pod 3개로 늘어났는지 확인
kubectl get pods -n helm-demo
```

---

## Step 8: Rollback

```bash
# 히스토리 확인
helm history my-release -n helm-demo
# REVISION  STATUS      CHART           DESCRIPTION
# 1         superseded  my-app-0.1.0   Install complete
# 2         superseded  my-app-0.1.0   Upgrade complete
# 3         deployed    my-app-0.1.0   Upgrade complete

# 1번 revision으로 롤백 (최초 설치 상태)
helm rollback my-release 1 -n helm-demo

# 확인 (revision 4가 생성됨)
helm history my-release -n helm-demo
kubectl get pods -n helm-demo  # replicas가 2로 돌아왔는지 확인
```

---

## Step 9: 삭제

```bash
# Release 삭제 (K8s 리소스 전부 제거)
helm uninstall my-release -n helm-demo

# 확인
helm list -n helm-demo
kubectl get pods -n helm-demo
```

---

## 트래픽 흐름 다이어그램

```
외부 요청
    │
    ▼ (Ingress.enabled=true 시)
[Ingress]
    │
    ▼
[Service: my-release-my-app]  ClusterIP:80
    │
    ▼
[Deployment: my-release-my-app]
    ├── Pod 1 (nginx:1.21.0)
    ├── Pod 2 (nginx:1.21.0)
    └── ...
```

---

## 자주 발생하는 문제

| 증상 | 원인 | 해결 |
|------|------|------|
| `Error: INSTALLATION FAILED: rendered manifests contain a resource that already exists` | 동일 이름의 K8s 리소스가 이미 있음 | 기존 리소스 삭제 후 재설치 |
| `Error: chart requires kubeVersion` | 클러스터 버전 불일치 | `Chart.yaml`의 `kubeVersion` 필드 확인 |
| Pod `ImagePullBackOff` | 이미지 태그 오타 또는 레지스트리 인증 실패 | `kubectl describe pod <name>`으로 원인 확인 |
| `helm rollback` 후 동일 상태 | 롤백한 revision이 현재와 동일 | `helm history`로 올바른 revision 번호 확인 |
