set -e

echo "PLAYING KUBE"
podman play kube stake_pod_config.yml

sleep 3

EXITED=( $(podman ps -a -f pod=stake_pod -f status=exited --noheading | rev | cut -d ' ' -f1 | rev) )

if [[ $EXITED == "" ]]
then
  echo "No containers exited after deployment."
  echo ""
else
  echo "The following containers did not deploy correctly:"
  for line in $EXITED; do
    echo $line
    podman logs $line
    echo ""
  done
fi

# echo "CLEANING UP"
# podman pod stop stake_pod
# sleep 2
# podman pod rm stake_pod