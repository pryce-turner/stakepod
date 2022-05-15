# StakePod
### Eth2 staking using Podman and the K8s pod spec for a quick and simple setup

## Motivation:
- easy setup / disaster recovery: deploy everything with as few commands / configs as possible
- easy maintenance / configuration: configure everything in one declarative place
- easy distribution: maintain a single template than can then be shared, configured and extended
- daemonless / rootless: leverage Podman for secure, low-overhead containers, with an eye for extending to a K8s cluster

## Quickstart
- `cd ~ && git clone (git repo) && cd stakepod`
- `cp stake_pod_template.yml stake_pod_config.yml`
- Configure `stake_pod_config.yml` following the comments
- `podman play kube stake_pod_config.yml`

## Steps:
1. Prep

Start by installing (or booting a VM of) the server distro of your choosing. Since we're using Podman, then Fedora or CentOS will play nice, but any popular Linux distro should work. On your fresh install you'll want to harden the node as much as possible, the [CoinCashew Security Best Practices](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node) are excellent.

setup template
how to import keys
systemd process for startup

todo:
monitoring
ansible? may be overkill
split config to avoid shared PID in lighthouse