# 인프라 차트 관리 전략

실무에서 CNCF/써드파티 Helm 차트를 관리하는 방법을 정리합니다.

---

## 디렉토리 구조

```
infra/
├── helmfile.yaml                  # 전체 스택 오케스트레이션
├── karpenter/
│   ├── values.yaml                # Helm chart 설치 설정 (operator)
│   ├── values-prod.yaml
│   └── resources/                 # CRD 인스턴스 (NodePool, EC2NodeClass)
│       ├── ec2nodeclass-default.yaml
│       ├── nodepool-default.yaml
│       └── nodepool-gpu.yaml
├── monitoring/
│   └── kube-prometheus-stack/
│       ├── values.yaml
│       ├── values-prod.yaml
│       └── resources/             # CRD 인스턴스 (PrometheusRule, AlertmanagerConfig)
│           ├── alertmanager-config.yaml
│           ├── prometheus-rules-kubernetes.yaml
│           └── prometheus-rules-application.yaml
└── cert-manager/
    ├── values.yaml
    └── resources/                 # CRD 인스턴스 (ClusterIssuer, Certificate)
        ├── cluster-issuers.yaml
        └── certificates.yaml
```

---

## CRD 관리 전략 — 핵심 개념

써드파티 차트를 설치하면 두 가지 레이어가 생깁니다.

```
┌─────────────────────────────────────────────────────┐
│  Layer 1: Operator / Controller (Helm으로 관리)       │
│  예) Prometheus Operator, Karpenter Controller        │
│  → values.yaml 로 설정, helmfile sync 으로 배포        │
├─────────────────────────────────────────────────────┤
│  Layer 2: CRD 인스턴스 (resources/ 로 분리 관리)       │
│  예) PrometheusRule, NodePool, ClusterIssuer          │
│  → kubectl apply -f resources/ 또는 ArgoCD로 배포     │
└─────────────────────────────────────────────────────┘
```

### --set 으로 할 수 있는 것 vs 없는 것

```bash
# 가능: chart values.yaml이 지원하는 설정
helm upgrade karpenter ... --set controller.resources.limits.memory=2Gi
helm upgrade kube-prometheus-stack ... --set prometheus.prometheusSpec.retention=30d

# 불가능: CRD 인스턴스는 --set 대상이 아님
# NodePool의 instance family 변경 → resources/nodepool-default.yaml 수정 후 kubectl apply
# PrometheusRule 추가 → resources/prometheus-rules-*.yaml 수정 후 kubectl apply
# ClusterIssuer 이메일 변경 → resources/cluster-issuers.yaml 수정 후 kubectl apply
```

### CRD 인스턴스 배포 방법

**방법 A: kubectl apply (간단)**
```bash
kubectl apply -f infra/karpenter/resources/
kubectl apply -f infra/monitoring/kube-prometheus-stack/resources/
kubectl apply -f infra/cert-manager/resources/
```

**방법 B: ArgoCD Application (GitOps 권장)**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: karpenter-resources
spec:
  source:
    path: infra/karpenter/resources
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

**방법 C: Helm post-install hook (차트 내부에서 처리)**
```yaml
# resources/nodepool-default.yaml 에 어노테이션 추가
metadata:
  annotations:
    "helm.sh/hook": post-install,post-upgrade
    "helm.sh/hook-weight": "5"
```

### CRD 스키마 업그레이드 주의사항

```bash
# chart 버전 올릴 때 CRD 스키마 변경이 있으면 Helm이 자동 업데이트 안 함
# 반드시 수동으로 CRD 먼저 업데이트
kubectl apply -f https://github.com/prometheus-operator/prometheus-operator/releases/download/v0.78.0/stripped-down-crds.yaml

# 그 다음 helmfile sync
helmfile -e prod sync -l app=monitoring
```

---

## 배포 순서

```bash
# 1. Operator 설치
helmfile -e prod sync --concurrency 1

# 2. CRD 인스턴스 배포 (operator 준비 후)
kubectl apply -f infra/cert-manager/resources/
kubectl apply -f infra/karpenter/resources/
kubectl apply -f infra/monitoring/kube-prometheus-stack/resources/
```
