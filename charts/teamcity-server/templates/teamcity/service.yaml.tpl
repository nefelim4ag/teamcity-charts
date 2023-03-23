---
apiVersion: v1
kind: Service
metadata:
  name: {{ $.Release.Name }}
spec:
  ports:
    - name: http
      protocol: TCP
      port: 8111
      targetPort: http
  selector:
    app: {{ $.Release.Name }}
    component: server
  type: ClusterIP
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $.Release.Name }}-headless
spec:
  type: ClusterIP
  clusterIP: None
  publishNotReadyAddresses: false
  ports:
    - name: http
      protocol: TCP
      port: 8111
      targetPort: http
  selector:
    app: {{ $.Release.Name }}
    component: server

{{- range $index, $value := $.Values.teamcity.nodes }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $.Release.Name }}-direct-{{ $index }}
  annotations:
    node-id: {{ $value.env.NODE_ID }}
spec:
  ports:
    - name: http
      protocol: TCP
      port: 8111
      targetPort: http
  selector:
    app: {{ $.Release.Name }}
    component: server
    statefulset.kubernetes.io/pod-name: {{ $.Release.Name }}-{{ $index }}
  type: ClusterIP
{{- end }}
