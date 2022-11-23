# Teamcity Server HA

# TL;DR
```
helm repo add teamcity-charts https://nefelim4ag.github.io/teamcity-charts/
helm install teamcity teamcity-charts/teamcity-server
```

# Description

Deploy multi-node ha Teamcity Server with nginx as reverse proxy. Use NFS/EFS for sharing data between nodes.
External database needed by config.
