# Helm 라이프사이클 가이드 — Install / Upgrade / Rollback

## Release란?
Chart를 클러스터에 설치한 인스턴스를 **Release**라고 합니다.
같은 Chart를 여러 번 설치하면 Release 이름만 다르게 해서 여러 인스턴스를 운영할 수 있습니다.

---

## 1. Install

```bash
# 기본 설치
helm install my-release charts/my-app

# 네임스페이스 지정 (없으면 자동 생성 가능)
helm install my-release charts/my-app -n production --create-namespace

# values 파일 적용
helm install my-release charts/my-app -f prod-values.yaml

# 개별 값 덮어쓰기
helm install my-release charts/my-app --set replicaCount=3 --set image.tag=2.0.0

# dry-run (실제 배포 없이 렌더링 결과 확인)
helm install my-release charts/my-app --dry-run --debug

# 설치 완료까지 대기 (모든 Pod Ready 상태)
helm install my-release charts/my-app --wait --timeout 5m
```

---

## 2. 설치 확인

```bash
# Release 목록
helm list
helm list -n production        # 특정 네임스페이스
helm list --all-namespaces     # 전체 네임스페이스

# Release 상태 확인
helm status my-release

# 렌더링된 실제 매니페스트 확인
helm get manifest my-release

# 적용된 values 확인
helm get values my-release           # 사용자 지정 값만
helm get values my-release --all     # 기본값 포함 전체

# Release 히스토리
helm history my-release
```

---

## 3. Upgrade

```bash
# Chart 코드 변경 후 업그레이드
helm upgrade my-release charts/my-app

# values 변경 적용
helm upgrade my-release charts/my-app -f prod-values.yaml

# 개별 값 변경
helm upgrade my-release charts/my-app --set image.tag=3.0.0

# 기존 values 유지하면서 일부만 변경 (--reuse-values)
helm upgrade my-release charts/my-app --reuse-values --set image.tag=3.0.0

# 설치 없으면 install, 있으면 upgrade (CI/CD에서 자주 사용)
helm upgrade --install my-release charts/my-app -f prod-values.yaml

# 실패 시 자동 롤백
helm upgrade my-release charts/my-app --atomic --timeout 3m
```

> `--atomic`: 업그레이드 실패 시 이전 버전으로 자동 롤백합니다.

---

## 4. Rollback

```bash
# 히스토리 확인
helm history my-release
# REVISION  STATUS      DESCRIPTION
# 1         superseded  Install complete
# 2         deployed    Upgrade complete
# 3         failed      Upgrade failed

# 바로 이전 버전으로 롤백
helm rollback my-release

# 특정 Revision으로 롤백
helm rollback my-release 1

# 대기하며 롤백
helm rollback my-release 1 --wait
```

---

## 5. Uninstall

```bash
# Release 삭제 (K8s 리소스 전부 제거)
helm uninstall my-release

# 히스토리도 함께 삭제
helm uninstall my-release --keep-history  # 히스토리 유지 (기본 삭제)

# 확인
helm list  # 목록에서 사라짐
```

---

## 6. Release 상태 흐름

```
helm install
     │
     ▼
[deployed]  ──── helm upgrade ──→  [deployed] (revision +1)
     │                                   │
     │                          실패 시 [failed]
     │                                   │
     └──────── helm rollback ────────────┘
                    │
                    ▼
             [deployed] (이전 revision 재활성화)
```

---

## 7. 자주 발생하는 문제

| 증상 | 원인 | 해결 |
|------|------|------|
| `Error: INSTALLATION FAILED: cannot re-use a name` | 동일 이름의 Release가 이미 존재 | `helm upgrade --install` 사용 |
| `Error: release has no deployed releases` | 모든 Revision이 failed 상태 | `helm uninstall` 후 재설치 |
| 업그레이드 후 Pod가 이전 버전으로 실행됨 | `--reuse-values`로 이전 image.tag가 유지됨 | `--set image.tag=새버전` 명시 |
| `helm list`에 표시 안 됨 | 다른 네임스페이스에 설치됨 | `helm list --all-namespaces` 확인 |
