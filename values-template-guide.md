# Values와 Go 템플릿 가이드

## 개요
Helm 템플릿은 Go의 `text/template` 패키지를 기반으로 합니다.
`values.yaml`의 값을 `{{ .Values.xxx }}` 형태로 참조하여 최종 K8s 매니페스트를 생성합니다.

---

## 1. 값 주입 방법

### 우선순위 (낮음 → 높음)
```
values.yaml 기본값
    ↓
부모 Chart의 values.yaml (Subchart 사용 시)
    ↓
-f / --values 파일
    ↓
--set 플래그 (가장 높은 우선순위)
```

```bash
# 파일로 값 덮어쓰기
helm install my-release charts/my-app -f prod-values.yaml

# 개별 값 덮어쓰기
helm install my-release charts/my-app --set replicaCount=3

# 중첩 키
helm install my-release charts/my-app --set image.tag=2.0.0

# 배열 값
helm install my-release charts/my-app --set "env[0].name=ENV,env[0].value=prod"
```

---

## 2. 내장 객체 (Built-in Objects)

| 객체 | 설명 | 예시 |
|------|------|------|
| `.Values` | values.yaml의 값 | `{{ .Values.replicaCount }}` |
| `.Release.Name` | Release 이름 | `my-release` |
| `.Release.Namespace` | 배포 네임스페이스 | `default` |
| `.Release.IsInstall` | 최초 설치 여부 | `true` / `false` |
| `.Chart.Name` | Chart 이름 | `my-app` |
| `.Chart.Version` | Chart 버전 | `0.1.0` |
| `.Chart.AppVersion` | 앱 버전 | `1.21.0` |
| `.Files` | Chart 내 일반 파일 접근 | `{{ .Files.Get "config.toml" }}` |

---

## 3. 주요 템플릿 문법

### 기본 출력
```yaml
# 단순 값 출력
replicas: {{ .Values.replicaCount }}

# 공백 제거 (- 사용)
name: {{- .Values.name -}}
```

### 조건문 (if/else)
```yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
...
{{- end }}

{{- if eq .Values.service.type "LoadBalancer" }}
  # LoadBalancer 전용 설정
{{- else if eq .Values.service.type "NodePort" }}
  # NodePort 전용 설정
{{- else }}
  # ClusterIP 기본 설정
{{- end }}
```

### 반복문 (range)
```yaml
env:
{{- range .Values.env }}
  - name: {{ .name }}
    value: {{ .value | quote }}
{{- end }}
```

values.yaml:
```yaml
env:
  - name: APP_ENV
    value: production
  - name: LOG_LEVEL
    value: info
```

### Named Template 호출 (include)
```yaml
metadata:
  name: {{ include "my-app.fullname" . }}
  labels:
    {{- include "my-app.labels" . | nindent 4 }}
```

> `include` vs `template`: `include`는 결과를 파이프라인으로 넘길 수 있어 `nindent` 같은 함수와 함께 사용합니다.

---

## 4. 주요 템플릿 함수

| 함수 | 설명 | 예시 |
|------|------|------|
| `quote` | 문자열을 따옴표로 감싸기 | `{{ .Values.tag \| quote }}` → `"1.0"` |
| `default` | 값이 없을 때 기본값 | `{{ .Values.port \| default 80 }}` |
| `toYaml` | 객체를 YAML 문자열로 변환 | `{{ .Values.resources \| toYaml }}` |
| `nindent` | 줄 앞에 N칸 들여쓰기 (개행 포함) | `\| nindent 4` |
| `indent` | 줄 앞에 N칸 들여쓰기 (개행 없음) | `\| indent 2` |
| `trunc` | 문자열 길이 제한 | `\| trunc 63` |
| `trimSuffix` | 특정 접미사 제거 | `\| trimSuffix "-"` |
| `upper` / `lower` | 대소문자 변환 | `\| upper` |
| `b64enc` | Base64 인코딩 | `\| b64enc` |
| `required` | 값이 없으면 에러 발생 | `{{ required "image.tag is required" .Values.image.tag }}` |

---

## 5. resources 블록 패턴 (toYaml + nindent)

`toYaml`과 `nindent`를 함께 사용하면 복잡한 중첩 구조를 그대로 주입할 수 있습니다.

```yaml
# templates/deployment.yaml
resources:
  {{- toYaml .Values.resources | nindent 10 }}
```

```yaml
# values.yaml
resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

렌더링 결과:
```yaml
resources:
          limits:
            cpu: 200m
            memory: 256Mi
          requests:
            cpu: 100m
            memory: 128Mi
```

---

## 6. with — 컨텍스트 범위 변경

```yaml
{{- with .Values.image }}
image: {{ .repository }}:{{ .tag }}
imagePullPolicy: {{ .pullPolicy }}
{{- end }}
```

> `with` 블록 내부에서 `.`는 `.Values.image`가 됩니다. 단, 상위 컨텍스트가 필요하면 `$`를 사용하세요.

---

## 7. 실전 패턴: 선택적 블록

```yaml
{{- if .Values.serviceAccount.create }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "my-app.serviceAccountName" . }}
  {{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
```
