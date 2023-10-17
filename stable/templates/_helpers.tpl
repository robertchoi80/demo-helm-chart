{{/*
Expand the name of the chart.
*/}}
{{- define "stable-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "stable-app.fullname" -}}
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
{{- define "stable-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "stable-app.labels" -}}
helm.sh/chart: {{ include "stable-app.chart" . }}
{{ include "stable-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "stable-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "stable-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "stable-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "stable-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "rollout-deploy-strategy" -}}
{{- if eq .Values.deploy.strategy.type "blueGreen" -}}
blueGreen:
  activeService: {{ .Release.Name }}-active-service
  previewService: {{ .Release.Name }}-preview-service
  {{- toYaml .Values.deploy.strategy.blueGreen | nindent 2 -}}
{{- else if eq .Values.deploy.strategy.type "canary" -}}
canary:
  {{- toYaml .Values.deploy.strategy.canary | nindent 2 -}}
{{- else if eq .Values.deploy.strategy.type "rollingUpdate" -}}
canary:
  {{- toYaml .Values.deploy.strategy.rollingUpdate | nindent 2 -}}
{{- end}}
{{- end }}

{{- define "stable-app.serviceName" -}}
{{- if eq .Values.deploy.strategy.type "blueGreen" }}
{{- printf "%s-%s" (include "stable-app.fullname" .) "active-service" }}
{{- else }}
{{- printf "%s-%s" (include "stable-app.fullname" .) "service" }}
{{- end }}
{{- end }}