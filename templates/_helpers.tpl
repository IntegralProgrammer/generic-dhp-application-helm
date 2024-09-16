{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "uhnapp.name" -}}
{{- required ".Values.appName must be specified!" .Values.appName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "uhnapp.fullname" -}}
{{- required ".Values.appName must be specified!" .Values.appName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "uhnapp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "uhnapp.labels" -}}
helm.sh/chart: {{ include "uhnapp.chart" . }}
{{ include "uhnapp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "uhnapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "uhnapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "uhnapp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "uhnapp.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "uhnapp.vaultRole" -}}
{{- default (printf "%s" .Release.Namespace) .Values.vault.role }}
{{- end -}}

{{- define "uhnapp.natsUri" -}}
{{- .Values.nats.uri | default (printf "nats://nats.%s.svc.cluster.local:4222" .Release.Namespace) }}
{{- end -}}

{{- define "uhnapp.mongoURL" -}}
{{- .Values.mongo.hostPort | default (printf "mongodb://{:- with secret %s -:}%s{: end :}@%s" (include "uhnapp.mongoAuthSecretPath" . | quote) (include "uhnapp.mongoAuthSecretCreds" . ) `{:- with secret "secret/mongo" -:}{: .Data.data.url :}{: end :}`)}}
{{- end -}}

{{- define "uhnapp.database" -}}
{{- .Values.mongo.database | default (printf "%s-%s" .Release.Namespace ( include "uhnapp.fullname" . )) }}
{{- end -}}

{{- define "uhnapp.mongoAuthSecretPath" -}}
{{- .Values.mongo.authSecretPath | default (printf "db/mongo.%s.svc.cluster.local/static-creds/%s" .Release.Namespace (include "uhnapp.database" . )) }}
{{- end -}}

{{- define "uhnapp.mongoAuthSecretCreds" -}}
{{- if .Values.mongo.authSecretIsKV -}}
    {: .Data.data.username :}:{: .Data.data.password :}
{{- else -}}
    {: .Data.username :}:{: .Data.password :}
{{- end -}}
{{- end -}}
