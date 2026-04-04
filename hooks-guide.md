# Helm Hooks 가이드

## Hooks란?
Helm 라이프사이클의 특정 시점에 추가 작업을 실행하는 메커니즘입니다.
DB 마이그레이션, 초기 데이터 삽입, 배포 후 검증 등에 활용합니다.

---

## 1. Hook 종류

| Hook | 실행 시점 |
|------|-----------|
| `pre-install` | Install 전, 리소스 렌더링 후 |
| `post-install` | Install 후, 모든 리소스 생성 완료 후 |
| `pre-upgrade` | Upgrade 전 |
| `post-upgrade` | Upgrade 후 |
| `pre-rollback` | Rollback 전 |
| `post-rollback` | Rollback 후 |
| `pre-delete` | Uninstall 전 |
| `post-delete` | Uninstall 후 |
| `test` | `helm test` 명령 실행 시 |

---

## 2. Hook 정의 방법

`helm.sh/hook` annotation을 추가하면 됩니다.

```yaml
# templates/db-migrate-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "my-app.fullname" . }}-db-migrate
  annotations:
    "helm.sh/hook": pre-install,pre-upgrade   # 복수 지정 가능
    "helm.sh/hook-weight": "-5"               # 실행 순서 (낮을수록 먼저)
    "helm.sh/hook-delete-policy": hook-succeeded  # 성공 시 자동 삭제
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: db-migrate
          image: my-app-migrator:latest
          command: ["python", "manage.py", "migrate"]
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: url
```

---

## 3. hook-delete-policy

Hook 리소스(Job, Pod 등)를 언제 삭제할지 지정합니다.

| 값 | 설명 |
|----|------|
| `hook-succeeded` | 성공 시 삭제 (기본값) |
| `hook-failed` | 실패 시 삭제 |
| `before-hook-creation` | 다음 번 Hook 실행 전에 이전 리소스 삭제 |

```yaml
annotations:
  "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
```

> `before-hook-creation`을 사용하면 매 upgrade마다 Job이 재실행됩니다.

---

## 4. hook-weight (실행 순서)

같은 Hook 시점에 여러 리소스가 있을 때, `hook-weight`로 순서를 제어합니다.
숫자가 작을수록 먼저 실행됩니다. 기본값은 `0`.

```yaml
# 1번: ConfigMap 생성
annotations:
  "helm.sh/hook": pre-install
  "helm.sh/hook-weight": "-10"

# 2번: DB 마이그레이션 Job
annotations:
  "helm.sh/hook": pre-install
  "helm.sh/hook-weight": "0"

# 3번: 데이터 시드 Job
annotations:
  "helm.sh/hook": pre-install
  "helm.sh/hook-weight": "5"
```

---

## 5. test Hook — helm test

배포된 Release가 정상 동작하는지 검증하는 Hook입니다.

```yaml
# templates/tests/test-connection.yaml
apiVersion: v1
kind: Pod
metadata:
  name: {{ include "my-app.fullname" . }}-test-connection
  annotations:
    "helm.sh/hook": test
spec:
  restartPolicy: Never
  containers:
    - name: wget
      image: busybox
      command: ['wget']
      args: ['{{ include "my-app.fullname" . }}:{{ .Values.service.port }}']
```

```bash
# 테스트 실행
helm test my-release

# 출력 포함
helm test my-release --logs
```

---

## 6. 실전 패턴: DB 마이그레이션

```
helm upgrade --install my-release charts/my-app
        │
        ▼
[pre-upgrade Hook] db-migrate Job 실행
        │
        ├── 성공 → Job 삭제 → Deployment 업그레이드
        └── 실패 → upgrade 중단 (--atomic이면 자동 rollback)
```

---

## 7. Hook 주의사항

- Hook 리소스는 `helm uninstall` 시 **자동 삭제되지 않습니다** (`hook-delete-policy` 미설정 시).
  필요하면 `post-delete` Hook이나 `hook-delete-policy: hook-succeeded`로 직접 관리하세요.
- `--wait` 플래그를 사용할 때 Hook Job이 완료될 때까지 기다립니다.
- Hook은 일반 템플릿보다 먼저 처리되므로, Hook에서 참조하는 Secret/ConfigMap은 Hook 안에서 생성하거나 별도로 먼저 배포해야 합니다.
