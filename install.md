# Helm 설치 및 기본 환경 설정

## 1. Helm 설치
---

### macOS (Homebrew)
```bash
brew install helm
```

### Linux (스크립트)
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### 버전 확인
```bash
helm version
# version.BuildInfo{Version:"v3.x.x", ...}
```

---

## 2. kubectl 연결 확인
---
Helm은 현재 `kubectl`의 kubeconfig 컨텍스트를 그대로 사용합니다.

```bash
# 현재 연결된 클러스터 확인
kubectl config current-context

# EKS 클러스터 연결 (예시)
aws eks update-kubeconfig --region ap-northeast-2 --name my-cluster
```

---

## 3. 기본 명령어 요약
---

| 명령어 | 설명 |
|--------|------|
| `helm repo add <name> <url>` | Chart Repository 추가 |
| `helm repo update` | Repository 캐시 갱신 |
| `helm search repo <keyword>` | Chart 검색 |
| `helm install <release> <chart>` | Chart 설치 |
| `helm upgrade <release> <chart>` | Chart 업그레이드 |
| `helm rollback <release> <revision>` | 이전 버전으로 롤백 |
| `helm uninstall <release>` | Release 삭제 |
| `helm list` | 설치된 Release 목록 |
| `helm status <release>` | Release 상태 확인 |
| `helm template <release> <chart>` | 렌더링 결과만 출력 (dry-run) |
| `helm lint <chart>` | Chart 문법 검사 |

---

## 4. Helm 주요 개념
---

| 용어 | 설명 |
|------|------|
| **Chart** | Helm 패키지. K8s 리소스 템플릿 묶음 |
| **Release** | Chart를 클러스터에 설치한 인스턴스. 같은 Chart를 여러 번 설치하면 Release도 여러 개 |
| **Repository** | Chart를 호스팅하는 저장소 (e.g. ArtifactHub, Bitnami) |
| **Values** | Chart 템플릿에 주입할 설정값 (`values.yaml` 또는 `--set`) |
| **Revision** | Release의 히스토리 버전 번호. 업그레이드/롤백 시 증가 |

---

## 5. 자주 쓰는 공개 Repository 추가
---

```bash
# Bitnami (nginx, postgresql, redis 등)
helm repo add bitnami https://charts.bitnami.com/bitnami

# Ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# Cert-manager
helm repo add jetstack https://charts.jetstack.io

# Prometheus / Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

# 전체 업데이트
helm repo update

# 추가된 저장소 확인
helm repo list
```
