#!/bin/bash

rm -Rf *.tgz
helm package quire ki-selfhost-operator-istio
helm repo index .
git add *

