#!/bin/bash

org=$1
if [ -z $org ]; then
    echo "please supply the owning namespace"
    exit 1
fi

site=$2
if [ -z $site ]; then
    echo "please supply a site name"
    exit 1
fi

domain=$3
preagree=false
if [ -z $domain ]; then
    domain="$site.eons.dev"
else [ $domain == y ]
  preagree=true
fi

namespace="$1"
release="$site"
#chart="cm/wordpress"
chart="/home/eons/git/fog/charts/hostpath/wordpress"

valuesPath="/home/eons/inf/k8s/helm/release/wp/${org}"
valuesFile="${valuesPath}/${release}.yaml"

if [ ! -f $valuesFile ]; then
    mkdir -pv $valuesPath
    cat << EOF > $valuesFile
deployment:
  priorityClass: dev-low
domain: $domain
secrets:
  letsencrypt:
    issuer: letsencrypt
    kind: ClusterIssuer
mysql:
  deployment:
    priorityClass: dev-low
	affinity:
      nodeSelectors:
      - key: serve
        value: dev
  secrets:
    password: $(rpass-alpha 32)
    rootpassword: $(rpass-alpha 32)
EOF
fi
if [ ! -f $valuesFile ]; then
    echo "ERROR: COULD NOT CREATE VALUES FILE"
    exit 1
fi

echo "#### values file is ####"
echo "# ${valuesFile}"
cat $valuesFile
echo "\n########################"

existenceCheck=$(helm ls -A | grep $namespace | grep $release)
echo $existenceCheck
if [ -z "$existenceCheck" ]; then
  echo "Could not find ${namespace}/${release}"
  echo "Will run:"
  echo "helm -n $namespace install $release $chart -f $valuesFile"
  if ! $preagree; then
  	read -p "Create new site? [Y/n] " -n 1 -r
  	echo ""
  	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      	exit 0
  	fi
  fi
	kubectl create namespace $namespace
	helm -n $namespace install $release $chart -f $valuesFile
	echo "Now hosting $site in namesapce $namespace"
else
  echo "${namespace}/${release} exists"
  echo "Will run:"
  echo "helm -n $namespace upgrade $release $chart -f $valuesFile"
  if ! $preagree; then
  	read -p "Upgrade? [Y/n] " -n 1 -r
  	echo ""
  	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      	exit 0
  	fi
  fi
	helm -n $namespace upgrade $release $chart -f $valuesFile
	echo "Upgraded $site"
fi