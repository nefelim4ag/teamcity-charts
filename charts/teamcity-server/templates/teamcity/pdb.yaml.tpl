{{- if .Values.pdb.enabled }}
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ $.Release.Name }}
  labels:
    app: {{ $.Release.Name }}
spec:
  selector:
    matchLabels:
      app: {{ $.Release.Name }}
      component: server
  minAvailable: {{ .Values.pdb.minAvailable }}
{{- end }}
