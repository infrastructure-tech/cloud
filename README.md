# Cloud Deployments for Eons Infrastructure Technologies

This is everything you need to set up a Kubernetes cluster on the Eons Infrastructure Technologies platform (EIT).

## Notes

1. We prefer yaml over helm charts wherever possible.
2. All of this assumes Linux only hosts and vms.
3. When deploying these, search for "CHANGEME" and make sure you're overriding all the necessary values.
4. We prefer to do things the "hard way"; solutions like MicroK8s are easy but have continually failed us.

## Design

EIT is intended to be used as a hierarchical / nested system of K8s clusters. Each client on the EIT platform will have their own cluster, which is hosted on top of another cluster. This provides reseller capabilities out of the box.

Storage and Compute should be separate wherever possible. We use Hostpath storage on our baremetal nodes and you are welcome to do the same in your VMs. The hostpath used then maps to an Rclone (or similar) remote synchronized storage system. This means VMs, clusters, and everything on top can be migrated between hosts using the native K8s scheduling semantics. It also means we can easily snapshot clusters at any point in time for disaster recovery and experimentation (usually).

## Supported Services

Right now, we support running the following in Kubernetes:
* [Keycloak](./charts/keycloak/README.md)
* [Nextcloud](./charts/nextcloud/README.md)
* [Wordpress](./charts/wordpress/README.md)
* [Virtual Machines](./charts/hostpath/vm/README.md)

## Getting Started

NOTE: Instructions on installing Kubernetes are currently outside the scope of this document. We'll try to point you to some good resources soon!

### Kubernetes

To get up and running with our K8s system, we recommend you first clone this repo and modify the necessary values (e.g. change the eons-admin-sa to your own service account).

Then, you can run the following commands to deploy the necessary services:

```bash
kubectl apply -R -f ./yaml/INSTALL
```

That will get you a basic cluster.

To access the dashboard, you'll need the token you get from (REPLACE eons-admin-sa with your service account):
```bash
kubectl get secret eons-admin-sa -n kube-system -o jsonpath={".data.token"} | base64 -d
```

To access the dashboard, run `kubectl proxy` and navigate to http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/ in your browser.

### Services

To deploy services, use the helm charts in the charts folder and make sure to copy and configure your own values.yaml.

For example, to create a new website, you could run:
```bash
helm install my-website ./charts/wordpress -f ~/git/infrastructure-tech/YOUR_CLIENT_NAME/deployment/wordpress/my-website.yaml
```
NOTE: that this assumes that both:
1. You have a cluster with EIT and have cloned it to the path above.
2. You have created and configured a my-website.yaml file in the deployment/wordpress folder.


For another example, to create a new virtual machine for their client's cluster called "worker-2", resellers could run:
```bash
helm install worker-2 ./charts/hostpath/vm/ -f ~/git/infrastructure-tech//RESELLER_NAME/client/CLIENT_NAME/deployment/vm/worker.yaml
```
Again, we assume that the values file provided has been created and configured.
NOTE: also make sure to provision any external disk images if you're using preconfigured images on external storage.