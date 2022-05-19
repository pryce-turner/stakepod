# StakePod
### Eth2 staking using Podman and the K8s pod spec for a quick and simple setup

## Motivation:
- easy setup / disaster recovery: deploy everything with as few commands / configs as possible
- easy maintenance / configuration: configure everything in one declarative place
- easy distribution: maintain a single template than can then be shared, configured and extended
- daemonless / rootless: leverage Podman for secure, low-overhead containers, with an eye for extending to a K8s cluster

## Quickstart
- `cd ~ && git clone https://github.com/pryce-turner/stakepod.git && cd stakepod`
- `cp stake_pod_template.yml stake_pod_config.yml`
- Configure `stake_pod_config.yml` following the comments
- `podman play kube stake_pod_config.yml`

## Steps:
1. Prep

    Start by installing (or booting a VM of) the server distro of your choosing. Since we're using Podman, then Fedora or CentOS will play nice, but any popular Linux distro should work. On your fresh install you'll want to harden the node as much as possible, the [CoinCashew Security Best Practices](https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node) are excellent.

2. (Optional) Configure Host Directories: If you plan on mounting directories for your containers instead of letting Podman manage them (for example if your storage is on another disk), then you'll need to configure the correct ownership and SELinux policies. 

    To set user permissions as they appear in the template, you'll use `podman unshare chown -R uid:gid /storage/on/host/`, to use the Erigon containers as an example, this would be `podman unshare chown -R 1000:1000 /storage/on/host/erigon`. You can read more about the unshare command [here](https://blog.christophersmart.com/2021/01/31/volumes-and-rootless-podman/) and [here](https://docs.podman.io/en/latest/markdown/podman-unshare.1.html).

    To set the correct SELinux policies you'll need to run `chcon -u system_u -t container_file_t -l s0:range -R /storage/on/host`. Again in the case of the Erigon bind-mount, `chcon -u system_u -t container_file_t -l s0:c100 -R /storage/on/host/erigon`. The context range and users are coded into the template, but can be changed to whatever. Additional info can be found in the [podman generate kube docs](https://docs.podman.io/en/latest/markdown/podman-generate-kube.1.html) and [here](https://opensource.com/article/18/2/selinux-labels-container-runtimes).

3. Configure Template

    Clone the template using `cp stake_pod_template.yml stake_pod_config.yml` and edit `stake_pod_config.yml` to suit your needs, following the comments. Most of the configuration comes down to what options you want to run the different clients with and storage. NOTE: If using persistentVolumeClaim, I encountered an issue where Podman wasn't assigning the correct user permissions to the lighthouse volume. I needed to run `podman volume inspect lighthouse-pvc` to obtain the path on disk, followed by manually running `podman unshare chown -R 2000:2000 /path/to/lighthouse-pvc`.

4. Import Keys

    If you're not migrating from an existing setup with chaindata and a validators folder, where you previously imported validators, you'll need to do that now. A fairly straightforward way to do this is just run the lighthouse container interactively with 2 mount points, both configured as above. For example: `podman run -ti --rm -v /path/to/validator_keys:/tmp -v /path/to/lighthouse/datadir/:/home sigp/lighthouse:latest lighthouse --datadir /home account validator import --directory /tmp` . You can also mount both volumes with the [:Z option](https://docs.podman.io/en/latest/markdown/podman-run.1.html), but please note this will override the host directory config from earlier, so that will need to be re-done.

5. Run it!

    With everything configured correctly, you should be able to simply `podman play kube stake_pod_config.yml`. You can check that things are running with `podman ps -a` and see what they're working on with `podman logs container_name`. The most common issues I ran into were permission related, please revisit user permissions and SELinux context if your containers exit due to "Permission Denied" errors.

## TODO:
- systemd process for startup
- monitoring
- split config to avoid shared PID in lighthouse