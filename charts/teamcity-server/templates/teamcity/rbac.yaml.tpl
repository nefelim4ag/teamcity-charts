{{- if $.Values.serviceAccount.enabled }}
{{- if $.Values.serviceAccount.agentRBAC.enabled }}
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{ $.Release.Name }}-agent-ctrl
rules:
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["list", "get"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "create", "list", "delete"]
- apiGroups: ["extensions", "apps"]
  resources: ["deployments"]
  verbs: ["list", "get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ $.Release.Name }}-agent-ctrl
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ $.Release.Name }}-agent-ctrl
subjects:
  - kind: ServiceAccount
    name: {{ $.Release.Name }}
{{- end }}
{{- end }}
