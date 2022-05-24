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
  selector:
    app: {{ $.Release.Name }}-proxy
  type: ClusterIP
