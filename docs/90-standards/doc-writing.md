# 문서 작성 원칙 — helm-practice

## 언어
- 본문은 한국어, 기술 용어(Chart.yaml, values.yaml, helpers.tpl)는 영어
- 서술체: `~다.`, `~한다.`

## 문서 구조
1. **개요** — 이 기능이 무엇을 해결하는지
2. **코드 예시** — 실제 동작 가능한 템플릿/values
3. **검증** — helm lint, helm template, helm diff
4. **배포** — helm install/upgrade 명령어
5. **트러블슈팅** — 자주 겪는 문제

## 코드 블록
- HCL/YAML에 한국어 `#` 주석
- `helm template`으로 렌더링 예시 포함
- `--dry-run` 또는 `--atomic` 옵션 명시

## 주의사항
- prod 배포: `> **prod 주의**:` 경고 블록
- secret 취급: `> **보안 주의**:` 경고 블록
