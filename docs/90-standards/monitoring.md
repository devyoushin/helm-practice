# 모니터링 지침 — helm-practice

## 배포 상태 확인

```bash
# 릴리즈 목록
helm list -A

# 특정 릴리즈 상태
helm status <release> -n <namespace>

# 릴리즈 히스토리
helm history <release> -n <namespace>

# 배포된 values 확인
helm get values <release> -n <namespace>

# 배포된 매니페스트 확인
helm get manifest <release> -n <namespace>
```

## Pod 상태 확인

```bash
# 배포된 Pod 확인
kubectl get pod -n <namespace> -l app.kubernetes.io/instance=<release>

# Pod 이벤트 확인
kubectl describe pod -n <namespace> -l app.kubernetes.io/instance=<release>
```

## 롤백 모니터링

```bash
# 이전 버전으로 롤백
helm rollback <release> <revision> -n <namespace>

# 롤백 후 상태 확인
helm status <release> -n <namespace>
helm history <release> -n <namespace>
```

## 차트 검증 자동화

```bash
# 린트
helm lint ./chart

# 모든 values 조합으로 렌더링 확인
helm template test ./chart -f values-dev.yaml > /dev/null
helm template test ./chart -f values-prod.yaml > /dev/null
```
