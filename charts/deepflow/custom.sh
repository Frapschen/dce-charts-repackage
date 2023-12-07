#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================
#===============================

set -o errexit
set -o pipefail
set -o nounset

#==============================

# add grafana testFramework value
sed -i '798a\  testFramework:' ./charts/deepflow/values.yaml
sed -i '799a\    enabled: true' ./charts/deepflow/values.yaml
sed -i '800a\    image:' ./charts/deepflow/values.yaml
sed -i '801a\      registry: docker.m.daocloud.io' ./charts/deepflow/values.yaml
sed -i '802a\      repository: bats/bats' ./charts/deepflow/values.yaml
sed -i '803a\      tag: "v1.4.1"' ./charts/deepflow/values.yaml
sed -i '804a\    imagePullPolicy: IfNotPresent' ./charts/deepflow/values.yaml
sed -i '805a\    securityContext: {}' ./charts/deepflow/values.yaml
sed -i '806G' ./charts/deepflow/values.yaml

# add grafana server config
sed -i '833a\    server:' ./charts/deepflow/values.yaml
sed -i '834a\      root_url: "%(protocol)s://%(domain)s:%(http_port)s/deepflow-grafana"' ./charts/deepflow/values.yaml
sed -i '835a\      serve_from_sub_path: true' ./charts/deepflow/values.yaml

# add GProductProxy for grafana
cat > ./charts/deepflow/templates/deepflow-proxy.yaml<<EOF
{{ if (lookup "ghippo.io/v1alpha1" "GProductProxy" "" "") }}
apiVersion: ghippo.io/v1alpha1
kind: GProductProxy
metadata:
  name: deepflow
spec:
  gproduct: deepflow
  proxies:
    - authnCheck: false
      destination:
        host: {{ .Release.Name }}-grafana.{{ .Release.Namespace }}.svc.cluster.local
        port: 80
      match:
        uri:
          prefix: /deepflow-grafana
{{ end }}
EOF

# add deepflow-agent costume value
sed -i '657a\    registry: "docker.m.daocloud.io"' ./charts/deepflow/values.yaml
sed -i '49 c\        image: "{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"' ./charts/deepflow/charts/deepflow-agent/templates/daemonset.yaml
sed -i '57 c\          image: "{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"' ./charts/deepflow/charts/deepflow-agent/templates/daemonset.yaml
sed -i '39 c\          image: "{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"' ./charts/deepflow/charts/deepflow-agent/templates/watcher-deployment.yaml

# add mysql costume value
sed -i '558a\    registry: "docker.m.daocloud.io"' ./charts/deepflow/values.yaml
sed -i '63 c\          image: "{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"' ./charts/deepflow/charts/mysql/templates/deployment.yaml
sed -i '46 c\        image: "{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}""' ./charts/deepflow/charts/mysql/templates/deployment.yaml

# add clickhouse costume value
sed -i '396a\    registry: "docker.m.daocloud.io"' ./charts/deepflow/values.yaml
sed -i '43 c\          image: "{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"' ./charts/deepflow/charts/clickhouse/templates/statefulset.yaml
sed -i '55 c\          image: "{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"' ./charts/deepflow/charts/clickhouse/templates/statefulset.yaml

# add app costume value
sed -i '72a\    registry: "docker.m.daocloud.io"' ./charts/deepflow/values.yaml
sed -i '41 c\          image: "{{ .Values.image.app.registry }}/{{ .Values.image.app.repository }}:{{ .Values.image.app.tag }}"' ./charts/deepflow/templates/app-deployment.yaml

# add server costume value
sed -i '68a\    registry: "docker.m.daocloud.io"' ./charts/deepflow/values.yaml
sed -i '47 c\          image: "{{ .Values.image.server.registry }}/{{ .Values.image.server.repository }}:{{ .Values.image.server.tag }}"' ./charts/deepflow/templates/server-deployment.yaml