# GitOps Configurations for Dev Cluster

This repo contains Argo CD configurations for all applications on the dev
cluster. It is a Helm chart which deploys Namespaces, AppProjects, and
Applications, based on configurations in values.yaml.

This repo is continuously pushed by ACM to the dev cluster.

## Deploying

This will deploy an ACM Application (Subscription and other required objects)
to continuously deploy this repo to the dev cluster:

```bash
./deploy.sh
```
