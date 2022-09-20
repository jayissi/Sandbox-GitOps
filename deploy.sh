#!/bin/bash
#
# This is a shell script so ACM doesn't pick up the YAML and try to deploy
# objects that already exist.
#

set -e

# Name of this GitOps Helm chart. Recommended: "gitops-<clustername>"
CHART_NAME="gitops-dev"

# URL to this repo. Should end in ".git"
REPO_URL="https://github.com/hello-world-gitops/gitops-dev.git"

oc create -f - << EOF
apiVersion: app.k8s.io/v1beta1
kind: Application
metadata:
  name: $CHART_NAME
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
          - $CHART_NAME
---
apiVersion: apps.open-cluster-management.io/v1
kind: Channel
metadata:
  annotations:
    apps.open-cluster-management.io/reconcile-rate: medium
  name: $CHART_NAME
  namespace: openshift-gitops
spec:
  type: Git
  pathname: "$REPO_URL"
---
apiVersion: apps.open-cluster-management.io/v1
kind: Subscription
metadata:
  annotations:
    apps.open-cluster-management.io/git-branch: main
    apps.open-cluster-management.io/git-path: '.'
    apps.open-cluster-management.io/reconcile-option: merge
  labels:
    app: $CHART_NAME
  name: $CHART_NAME
  namespace: openshift-gitops
spec:
  channel: openshift-gitops/$CHART_NAME
  placement:
    placementRef:
      kind: PlacementRule
      name: $CHART_NAME
  # If you don't have this packageOverrides section, the HelmRelease that is
  # created will error because the chartPath is set to "/tmp/<namespace>/<channel>-local".
  # Not sure if it's a bug or expected.
  packageOverrides:
    - packageName: $CHART_NAME
      packageOverrides:
        - path: repo.source.git.chartPath
          value: '.'
---
apiVersion: apps.open-cluster-management.io/v1
kind: PlacementRule
metadata:
  labels:
    app: $CHART_NAME
  name: $CHART_NAME
  namespace: openshift-gitops
spec:
  clusterSelector:
    matchLabels:
      'local-cluster': 'true'
EOF
