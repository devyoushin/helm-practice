{{/*
Expand the name of the chart.
*/}}
{{- define "production-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
Release 이름이 chart 이름을 포함하면 중복을 방지합니다.
*/}}
{{- define "production-app.fullname" -}}
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

{{/*
Chart 레이블 (버전 추적용)
*/}}
{{- define "production-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
공통 레이블 — 모든 리소스에 붙입니다.
*/}}
{{- define "production-app.labels" -}}
helm.sh/chart: {{ include "production-app.chart" . }}
{{ include "production-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
셀렉터 레이블 — Deployment/Service 매칭에 사용. 배포 후 변경 불가.
*/}}
{{- define "production-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "production-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount 이름 결정
*/}}
{{- define "production-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "production-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
ConfigMap 이름
*/}}
{{- define "production-app.configMapName" -}}
{{- printf "%s-config" (include "production-app.fullname" .) }}
{{- end }}

{{/*
Secret 이름
*/}}
{{- define "production-app.secretName" -}}
{{- printf "%s-secret" (include "production-app.fullname" .) }}
{{- end }}
