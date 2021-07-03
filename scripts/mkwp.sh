#!/bin/bash

site=$1

if [ -z $site ]; then
   echo "please supply a site name"
   exit 1
fi

domain=$2
if [ -z $domain ];then
  domain="$site.sites.eons.dev"
fi

namespace="wp-$site"
release="$site"
chart="cm/wordpress"

valuesPath="/mnt/d/cloud/dust/me/proj/tamriel/k8s/helm/release/wp/${release}"
valuesFile="${valuesPath}/values.yaml"



if [ ! -f $valuesFile ]; then
  mkdir -pv $valuesPath
    cat << EOF > $valuesFile
deployment:
  priorityClass: dev-low
domain: $domain
secrets:
  letsencrypt:
    issuer: letsencrypt-staging
    kind: ClusterIssuer
mysql:
  deployment:
    priorityClass: dev-low
  secrets:
    password: $(rpass-alpha 32)
    rootpassword: $(rpass-alpha 32)
  affinity:
    nodeSelectors:
    - key: serve
      value: dev
EOF
fi
if [ ! -f $valuesFile ]; then
    echo "ERROR: COULD NOT CREATE VALUES FILE"
    exit 1
fi

# kubectl create namespace $namespace
echo "helm -n $namespace install $release $chart -f $valuesFile"
# helm -n $namespace install $release $chart -f $valuesFile
echo "Now hosting $domain in namesapce $namespace"
