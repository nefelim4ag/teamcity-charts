{{- with .Values.pvc }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .name }}
  annotations:
{{ .annotations | toYaml | indent 4 }}
spec:
  accessModes: {{ .accessModes | toJson }}
  resources: {{ .resources | toJson }}
  storageClassName: {{ .storageClassName }}
  volumeMode: Filesystem
{{- end }}

{{- range $key, $value := $.Values.teamcity }}
{{- with $.Values.ephemeral }}
{{- range $volume, $v_values := . }}
{{- if $v_values.enabled }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ $.Release.Name }}-{{ $key }}-{{ $volume }}
  annotations:
{{ $v_values.annotations | toYaml | indent 4 }}
spec:
  accessModes: {{ $v_values.accessModes | toJson }}
  resources: {{ $v_values.resources | toJson }}
  storageClassName: {{ $v_values.storageClassName }}
  volumeMode: Filesystem
{{- end }}
{{- end }}
{{- end }}
{{- end }}
