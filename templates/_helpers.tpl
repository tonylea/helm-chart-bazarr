{{- define "bazarr.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "bazarr.labels" -}}
{{ include "bazarr.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end }}

{{/* Without the chart's version, so a release that changes only the chart doesn't restart Bazarr. */}}
{{- define "bazarr.podLabels" -}}
{{ include "bazarr.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{- define "bazarr.secretKeyRef" -}}
{{- $path := index . 0 }}
{{- $ref := (index . 1).secretKeyRef }}
secretKeyRef:
  name: {{ required (printf "%s.secretKeyRef.name is required" $path) $ref.name }}
  key: {{ required (printf "%s.secretKeyRef.key is required" $path) $ref.key }}
{{- end }}

{{- define "bazarr.claimName" -}}
{{- $root := index . 0 }}
{{- $name := index . 1 }}
{{- (index $root.Values.persistence $name).existingClaim | default (printf "%s-%s" $root.Release.Name $name) }}
{{- end }}
