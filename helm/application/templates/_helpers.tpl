{{- define "application.fullname" -}}
{{- default .Release.Name .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "application.selectorLabels" -}}
app.kubernetes.io/name: {{ include "application.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "application.labels" -}}
{{ include "application.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | quote }}
{{- end -}}

{{- define "application.claimName" -}}
{{- default (printf "%s-data" (include "application.fullname" .)) .Values.persistence.existingClaim -}}
{{- end -}}

{{- define "application.probe" -}}
{{- $probe := deepCopy .probe -}}
{{- $handlers := 0 -}}
{{- range $handler := list "httpGet" "exec" "tcpSocket" "grpc" -}}
{{- if hasKey $probe $handler -}}
{{- if kindIs "invalid" (get $probe $handler) -}}
{{- $_ := unset $probe $handler -}}
{{- else -}}
{{- $handlers = add1 $handlers -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if gt (int $handlers) 1 -}}
{{- fail (printf "%s must contain exactly one health check handler" .name) -}}
{{- end -}}
{{- if eq (int $handlers) 0 -}}
{{- $_ := set $probe "httpGet" (dict "path" .root.Values.healthCheckPath "port" .root.Values.service.portName) -}}
{{- end -}}
{{- toYaml $probe -}}
{{- end -}}
