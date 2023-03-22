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
  publishNotReadyAddresses: true
  ports:
    - name: http
      protocol: TCP
      port: 8111
      targetPort: http
  selector:
    app: {{ $.Release.Name }}
    component: server
