{{- range $key, $value := .Values.teamcity }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $.Release.Name }}-{{ $key }}
spec:
  ports:
    - name: http
      protocol: TCP
      port: 8111
      targetPort: http
  selector:
    app: {{ $.Release.Name }}
    component: {{ $key }}
  type: ClusterIP
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $.Release.Name }}-{{ $key }}-headless
spec:
  type: ClusterIP
  clusterIP: None
  ports:
    - name: http
      protocol: TCP
      port: 8111
      targetPort: http
  selector:
    app: {{ $.Release.Name }}
    component: {{ $key }}
{{- end }}
