set -e

echo "PLAYING KUBE"
echo ""
podman play kube stake_pod_config.yml

sleep 3

echo "Containers deployed, any failures will print below:"
for line in $(podman ps -a -f pod=stake_pod -f status=exited --noheading | rev | cut -d ' ' -f1 | rev) ; do
  echo $line
  podman logs $line
  echo ""
done

echo ""
echo "CLEANING UP"
podman pod stop stake_pod
sleep 2
podman pod rm stake_pod