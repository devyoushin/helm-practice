# Helm Release 업그레이드 가이드

Helm upgrade는 기존 release의 chart, values, image tag, Kubernetes manifest를 새 revision으로 반영합니다. 운영 환경에서는 diff, dry-run, atomic 옵션을 사용해 실패 시 자동 롤백되도록 실행합니다.

## 1. 사전 점검

```bash
export RELEASE="my-release"
export CHART="bitnami/nginx"
export NAMESPACE="default"
export VALUES_FILE="values.yaml"

helm status ${RELEASE} -n ${NAMESPACE}
helm history ${RELEASE} -n ${NAMESPACE}
helm get values ${RELEASE} -n ${NAMESPACE} > values-before-upgrade.yaml
```

`helm diff` 플러그인이 있으면 실제 변경 리소스를 먼저 확인합니다.

```bash
helm plugin list
helm diff upgrade ${RELEASE} ${CHART} \
  --namespace ${NAMESPACE} \
  --values ${VALUES_FILE}
```

## 2. 업그레이드 실행

이 저장소의 실행 스크립트를 사용합니다.

```bash
RELEASE=${RELEASE} \
CHART=${CHART} \
NAMESPACE=${NAMESPACE} \
VALUES_FILE=${VALUES_FILE} \
./ops/upgrade/upgrade-helm-release.sh
```

직접 실행하려면 아래 명령을 사용합니다.

```bash
helm upgrade --install ${RELEASE} ${CHART} \
  --namespace ${NAMESPACE} \
  --create-namespace \
  --values ${VALUES_FILE} \
  --atomic \
  --timeout 10m
```

`--atomic`은 업그레이드 실패 시 자동 rollback을 수행합니다. Hook Job이나 긴 migration이 있으면 `--timeout`을 충분히 늘립니다.

## 3. 확인

```bash
helm status ${RELEASE} -n ${NAMESPACE}
helm history ${RELEASE} -n ${NAMESPACE}
kubectl get all -n ${NAMESPACE}
```

워크로드별로 `kubectl rollout status deployment/<NAME> -n ${NAMESPACE}`를 실행해 새 revision 반영을 확인합니다.

## 4. 롤백

```bash
helm history ${RELEASE} -n ${NAMESPACE}
helm rollback ${RELEASE} <REVISION> -n ${NAMESPACE} --wait
helm status ${RELEASE} -n ${NAMESPACE}
```

데이터베이스 schema migration처럼 비가역 변경이 있는 chart는 Helm rollback만으로 애플리케이션 상태가 완전히 돌아가지 않을 수 있습니다.

