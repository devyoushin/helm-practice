Helm 트러블슈팅 케이스를 추가합니다.

**사용법**: `/add-troubleshooting <증상 설명>`

**예시**: `/add-troubleshooting helm upgrade 후 Pod CrashLoopBackOff`

다음 형식으로 작성하고 `tips-guide.md`의 트러블슈팅 섹션에 추가하세요:

```markdown
### <증상>

**원인**: <근본 원인>

**확인 방법**:
\`\`\`bash
helm status <release> -n <namespace>
helm history <release> -n <namespace>
kubectl describe pod -n <namespace>
\`\`\`

**해결**:
\`\`\`bash
helm rollback <release> <revision> -n <namespace>
\`\`\`

**예방**: <--atomic 플래그 사용 등>
```
