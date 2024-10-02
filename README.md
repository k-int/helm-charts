

Update chart with

    helm dependency build ./ki-selfhost-operator
    helm package quire ki-selfhost-operator
    helm repo index .
