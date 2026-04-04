# Chart 의존성(Dependencies) 가이드

## 의존성이란?
애플리케이션 Chart가 다른 Chart(예: PostgreSQL, Redis)를 필요로 할 때,
`Chart.yaml`의 `dependencies` 필드에 Subchart를 선언합니다.

---

## 1. Chart.yaml에 의존성 선언

```yaml
# Chart.yaml
apiVersion: v2
name: my-app
version: 0.1.0

dependencies:
  - name: postgresql
    version: "12.x.x"
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled   # values.yaml의 이 값이 true일 때만 설치

  - name: redis
    version: "17.x.x"
    repository: https://charts.bitnami.com/bitnami
    condition: redis.enabled

  - name: common
    version: "2.x.x"
    repository: https://charts.bitnami.com/bitnami
    tags:
      - backend-deps             # tag로 그룹화하여 일괄 활성/비활성 가능
```

---

## 2. 의존성 다운로드

```bash
# 선언된 의존성 다운로드 → charts/ 디렉토리에 .tgz로 저장
helm dependency update charts/my-app

# 이미 charts/에 있는 의존성만 설치 (update 없이)
helm dependency build charts/my-app

# 의존성 목록 확인
helm dependency list charts/my-app
```

실행 후 구조:
```
charts/my-app/
├── Chart.yaml
├── Chart.lock          # 실제 사용된 버전 고정 (lockfile)
├── values.yaml
├── charts/
│   ├── postgresql-12.x.x.tgz
│   └── redis-17.x.x.tgz
└── templates/
```

---

## 3. Subchart Values 설정

부모 Chart의 `values.yaml`에서 Subchart의 값을 제어합니다.
**Subchart 이름을 키로 사용**합니다.

```yaml
# 부모 values.yaml

postgresql:
  enabled: true
  auth:
    database: mydb
    username: myuser
    password: mysecret
  primary:
    persistence:
      enabled: true
      size: 10Gi

redis:
  enabled: false   # condition과 매핑 → 비활성화

# 내 앱 설정
replicaCount: 2
image:
  repository: my-app
  tag: "1.0.0"
```

---

## 4. Global Values

모든 Chart(부모 + Subchart)에서 공통으로 접근할 수 있는 값입니다.
`global` 키워드를 사용합니다.

```yaml
# 부모 values.yaml
global:
  imageRegistry: my-registry.example.com
  storageClass: gp3

# Subchart templates에서
image: {{ .Values.global.imageRegistry }}/{{ .Values.image.repository }}
```

---

## 5. condition과 tags

### condition
`values.yaml`의 특정 키 값이 `true`일 때만 해당 Subchart를 설치합니다.

```yaml
# Chart.yaml
dependencies:
  - name: postgresql
    condition: postgresql.enabled

# values.yaml
postgresql:
  enabled: true  # ← 이 값으로 제어
```

### tags
여러 Subchart를 하나의 태그로 묶어 일괄 활성/비활성합니다.

```yaml
# Chart.yaml
dependencies:
  - name: postgresql
    tags: [backend]
  - name: redis
    tags: [backend]

# values.yaml (tags로 비활성화)
tags:
  backend: false
```

---

## 6. 로컬 Chart를 의존성으로 사용

공개 Repository 없이 로컬 Chart를 의존성으로 연결합니다.

```yaml
# Chart.yaml
dependencies:
  - name: common-library
    version: "0.1.0"
    repository: "file://../common-library"
```

```bash
helm dependency update charts/my-app
```

---

## 7. Chart.lock 파일

`helm dependency update` 실행 시 생성되는 버전 고정 파일입니다.
Git에 함께 커밋하여 팀 전체가 동일 버전을 사용하도록 합니다.

```yaml
# Chart.lock (자동 생성, 직접 수정 금지)
dependencies:
- name: postgresql
  repository: https://charts.bitnami.com/bitnami
  version: 12.5.6     # 실제 설치된 버전
- name: redis
  repository: https://charts.bitnami.com/bitnami
  version: 17.11.3
digest: sha256:abc123...
generated: "2024-01-01T00:00:00.000000000Z"
```

---

## 8. 의존성 흐름 요약

```
Chart.yaml (dependencies 선언)
        │
        ▼
helm dependency update
        │
        ▼
charts/ 디렉토리에 .tgz 다운로드 + Chart.lock 생성
        │
        ▼
helm install/upgrade
        │
        ├── 부모 templates/ 렌더링
        └── Subchart(charts/*.tgz) 렌더링
                   ↑
            condition이 true인 것만
```
