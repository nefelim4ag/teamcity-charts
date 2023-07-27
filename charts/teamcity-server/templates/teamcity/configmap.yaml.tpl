---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $.Release.Name }}-datadir-config
data:
{{ tpl ($.Values.configMap.datadirConfig | toYaml) $ | indent 4 }}

{{ if $.Values.configMap.optConf }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $.Release.Name }}-opt-conf
data:
{{ tpl ($.Values.configMap.optConf | toYaml) $ | indent 4 }}
{{ end }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $.Release.Name }}-startup-wrp
data:
  run-services-wrp.sh: |
    #!/bin/bash
    HOSTNAME=$(cat /etc/hostname)

    initfile=${TEAMCITY_DATA_PATH}/system/dataDirectoryInitialized
    if [ "$HOSTNAME" == "{{ $.Release.Name }}-0" ]; then
      if [ ! -f $initfile ]; then
        echo $initfile not found
        echo Assume initial setup
        index=0
        while [ -d ${TEAMCITY_DATA_PATH}/config.back.$index ]; do
          index=$((index + 1))
        done
        echo Hide mounted files
        mv -v ${TEAMCITY_DATA_PATH}/config ${TEAMCITY_DATA_PATH}/config.back.$index
      fi
    fi

    set -x
{{- range $index, $value := .Values.teamcity.nodes }}
    if [ "$HOSTNAME" == "{{ $.Release.Name }}-{{ $index }}" ]; then
{{- with $value.env }}
{{- range $e, $value := . }}
      export {{ $e }}="{{ tpl ($value) $ }}"
{{- end }}
{{- end }}
      export TEAMCITY_SERVER_OPTS="-Dteamcity.server.nodeId=${NODE_ID} -Dteamcity.server.rootURL=${ROOT_URL} $TEAMCITY_SERVER_OPTS"
      exec /run-services.sh
    fi
{{- end }}
