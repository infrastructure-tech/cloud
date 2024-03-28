# Helm Chart for Virtual Services

This chart uses [KubeVirt](https://kubevirt.io/) to create an [img_guest](https://github.com/infrastructure-tech/img_guest) that runs on an [img_host](https://github.com/infrastructure-tech/img_host) and can be accessed at a user-defined domain.

## Usage

Currently, there is no fancy EBBS -> EMI pipeline for helm charts, so just go ahead, clone the repo, and use the src folder for helm.

Configuration is largely undocumented at the moment but should be fairly intuitive; just take a look at the config file for options.

### Ports

Only the following ports are available on Eons' Infrastructure Technologies platform.  
These ports are [what Cloudflare allows us](https://developers.cloudflare.com/fundamentals/get-started/reference/network-ports/) for some reason.
* 80
* 443
* 2052
* 2053
* 2082
* 2083
* 2086
* 2087
* 2095
* 2096
* 8080
* 8880
* 8443

What this really means is that there is a limit on the number of virtual networks that you can create. This is because each port can [host a VPN](https://github.com/eons-dev/build_docker#networks). So, while not being able to hit ports like 6443 directly is inconvenient, you should still be able to achieve all the network connectivity you need with a private network + entrypoint design.