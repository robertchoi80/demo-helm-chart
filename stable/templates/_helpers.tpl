{{/*
Expand the name of the chart.
*/}}
{{- define "skb-app-gradle.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "skb-app-gradle.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "skb-app-gradle.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "skb-app-gradle.labels" -}}
helm.sh/chart: {{ include "skb-app-gradle.chart" . }}
{{ include "skb-app-gradle.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "skb-app-gradle.selectorLabels" -}}
app.kubernetes.io/name: {{ include "skb-app-gradle.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "skb-app-gradle.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "skb-app-gradle.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "rollout-deploy-strategy" -}}
{{- if eq .Values.deploy.strategy.type "blueGreen" }}
blueGreen:
  activeService: {{ .Release.Name }}-active-service
  previewService: {{ .Release.Name }}-preview-service
  {{- range $key, $value := .Values.deploy.strategy.blueGreen }}
  {{ $key }}: {{ $value }}
  {{- end }}
{{- else if eq .Values.deploy.strategy.type "canary" }}
canary:
  {{- with .Values.deploy.strategy.canary }}
  {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end}}
{{- end }}
