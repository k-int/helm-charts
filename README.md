

General

Advice: If using rancher desktop, please disable traefik installation, this distribution
relies upon the kong ingress gateway. Whilst the two can coexist given sufficient
load balancer resources, it is less confusing to install only one.

Update chart with

    helm dependency update ./ki-selfhost-operator  (Or build)
    helm package quire ki-selfhost-operator
    helm repo index .

## Usage

helm repo add https://k-int.github.io/helm-charts/
helm repo update
helm show values k-int/ki-selfhost-operator > my-values.yaml
helm install folio1 k-int/ki-selfhost-operator --values my-values.yaml --namespace folio1 --create-namespace

# Quire

Can be run stand-alone or installed by the selfhost operator.

## Quire Standalone

Needs kong gateway, pgo and elasticsearch as dependencies. 

### ECK Operator

    helm repo add elastic https://helm.elastic.co
    helm repo update 
    helm install elastic-operator elastic/eck-operator -n elastic-system --create-namespace
