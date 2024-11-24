

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


