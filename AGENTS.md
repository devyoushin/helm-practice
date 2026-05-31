# AGENTS.md — helm-practice Codex 작업 지침

이 저장소는 Helm chart와 Helmfile 학습/운영 지식 베이스입니다. Codex 작업 시 `CLAUDE.md`와 `docs/rules/`의 규칙을 동일하게 따릅니다.

## 공통 원칙

- Helm 개념과 가이드는 `docs/`에 둡니다.
- Chart, values, helmfile, 설치/업그레이드 스크립트는 `ops/`에 둡니다.
- chart 예시는 환경별 values 분리, rollback, diff, atomic upgrade를 고려합니다.
- Helm template 파일은 일반 YAML 파서가 실패할 수 있으므로 `helm lint` 또는 `helm template` 기준으로 검증합니다.

## Claude와의 싱크

- Claude 지침은 `CLAUDE.md`를 참고합니다.
- Codex도 공통 규칙은 `docs/rules/`를 따릅니다.
- 구조 변경 시 `README.md`, `docs/README.md`, `ops/README.md`를 함께 확인합니다.

## 작업 체크리스트

- `git status --short` 확인
- shell script는 `bash -n` 검사
- chart 변경 시 가능하면 `helm lint` 또는 `helm template` 실행
- 링크 검사와 `git diff --check` 수행
