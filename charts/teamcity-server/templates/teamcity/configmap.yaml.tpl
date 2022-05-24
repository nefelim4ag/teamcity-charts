---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $.Release.Name }}-datadir-config
data:
{{ tpl ($.Values.configMap.datadirConfig | toYaml) $ | indent 4 }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $.Release.Name }}-opt-conf
data:
{{ tpl ($.Values.configMap.optConf | toYaml) $ | indent 4 }}
