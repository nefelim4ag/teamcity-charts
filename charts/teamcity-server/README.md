# Teamcity Server HA

# TL;DR
```
helm repo add teamcity-charts https://nefelim4ag.github.io/teamcity-charts/
helm install teamcity teamcity-charts/teamcity-server
```

# Upgrade 1.2.x -> 2.x.x

* Migrated to statefulset
* Make PDB working
* Per node env & ingress moved to `teamcity.nodes[]`
* Per node env override works by entrypoint wrapper
* Dropped custom teamcity cache path from args
* Hide defaults for TEAMCITY_SERVER_OPTS because of: https://github.com/helm/helm/issues/5568. You still can set it to arbitrary value, it will be concatenated.

# Description

Deploy multi-node ha Teamcity Server with nginx as reverse proxy. Use NFS/EFS for sharing data between nodes.
External database needed by config.
