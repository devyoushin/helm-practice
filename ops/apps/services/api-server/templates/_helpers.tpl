{{/*
공통 헬퍼 함수
*/}}

{{/* 차트 이름 */}}
{{- define "api-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* 릴리즈 전체 이름 */}}
{{- define "api-server.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/* 공통 레이블 */}}
{{- define "api-server.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "api-server.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* 셀렉터 레이블 */}}
{{- define "api-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "api-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* ServiceAccount 이름 */}}
{{- define "api-server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "api-server.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Ingress host */}}
{{- define "api-server.ingressHost" -}}
{{- if .Values.ingress.host }}
{{- .Values.ingress.host }}
{{- else if .Values.global.domain }}
{{- printf "api.%s" .Values.global.domain }}
{{- else }}
{{- fail "ingress.host 또는 global.domain을 설정해주세요" }}
{{- end }}
{{- end }}
