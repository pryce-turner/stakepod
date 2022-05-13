set -e

echo "PLAYING KUBE"
podman play kube stake_pod_config.yml

sleep 3

EXITED=$(podman ps -a -f pod=stake_pod -f status=exited --noheading)

if [[ $EXITED == "" ]]
then
  echo "No containers exited after deployment."
  echo ""
else
  echo "The following containers did not deploy correctly:"
  echo $EXITED
  echo ""
fi

echo "CLEANING UP"
podman pod stop stake_pod
podman pod rm stake_pod