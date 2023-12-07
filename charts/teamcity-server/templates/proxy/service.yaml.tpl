---
apiVersion: v1
kind: Service
metadata:
  name: {{ $.Release.Name }}-proxy
spec:
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: http
    - name: stats
      protocol: TCP
      port: 8080
      targetPort: stats
  selector:
    app: {{ $.Release.Name }}-proxy
  type: ClusterIP
