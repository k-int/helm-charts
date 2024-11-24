

General

Advice: If using rancher desktop, please disable traefik installation, this distribution
relies upon the kong ingress gateway. Whilst the two can coexist given sufficient
load balancer resources, it is less confusing to install only one.

Update chart with

    helm dependency update ./ki-selfhost-operator  (Or build)
    helm package quire ki-selfhost-operator
    helm repo index .


# Quire

Can be run stand-alone or installed by the selfhost operator.

## Quire Standalone

Needs kong gateway, pgo and elasticsearch as dependencies. 

### PGO

The following command installs PGO and uses it to manage postgres installations
in any namespace created with pgo-managed=true

    helm install pgo oci://registry.developers.crunchydata.com/crunchydata/pgo \
      --namespace pgo \
      --create-namespace \
      --set global.namespace="" \
      --set pgo.namespaceSelector.matchLabels.pgo-managed=true

Create managed namespaces with the command

    kubectl create namespace namespace1
    kubectl label namespace namespace1 pgo-managed=true

We use the managed namespace approach in case there is a need/desire to switch to
CloudNativePG in the future.

### Kong Gateway

    helm repo add kong https://charts.konghq.com
    helm repo update kong
    helm install kong-operator kong/gateway-operator \
      --namespace kong-operator \
      --create-namespace

### ECK Operator

    helm repo add elastic https://helm.elastic.co
    helm repo update 
    helm install elastic-operator elastic/eck-operator -n elastic-system --create-namespace
