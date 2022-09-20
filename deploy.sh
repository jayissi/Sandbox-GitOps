#!/bin/bash
#
# This is a shell script so ACM doesn't pick up the YAML and try to deploy
# objects that already exist.
#

set -e

oc create -f - << EOF
apiVersion: app.k8s.io/v1beta1
kind: Application
metadata:
  name: theme-park-api
  namespace: openshift-gitops
spec:
  componentKinds:
  - group: apps.open-cluster-management.io
    kind: Subscription
  descriptor: {}
  selector:
    matchExpressions:
      - key: app
        operator: In
        values:
          - theme-park-api
---
apiVersion: apps.open-cluster-management.io/v1
kind: Channel
metadata:
  annotations:
    apps.open-cluster-management.io/reconcile-rate: medium
  name: gitops-dev
  namespace: openshift-gitops
spec:
  type: Git
  pathname: 'https://github.com/hello-world-gitops/gitops-dev.git'
---
apiVersion: apps.open-cluster-management.io/v1
kind: Subscription
metadata:
  annotations:
    apps.open-cluster-management.io/git-branch: main
    apps.open-cluster-management.io/git-path: '.'
    apps.open-cluster-management.io/reconcile-option: merge
  labels:
    app: theme-park-api
  name: theme-park-api
  namespace: openshift-gitops
spec:
  channel: openshift-gitops/gitops-dev
  placement:
    placementRef:
      kind: PlacementRule
      name: theme-park-api
  # If you don't have this packageOverrides section, the HelmRelease that is
  # created will error because the chartPath is set to "/tmp/<namespace>/<channel>-local".
  # Not sure if it's a bug or expected.
  packageOverrides:
    - packageName: gitops-dev
      packageOverrides:
        - path: repo.source.git.chartPath
          value: '.'
---
apiVersion: apps.open-cluster-management.io/v1
kind: PlacementRule
metadata:
  labels:
    app: theme-park-api
  name: theme-park-api
  namespace: openshift-gitops
spec:
  clusterSelector:
    matchLabels:
      'local-cluster': 'true'
EOF
