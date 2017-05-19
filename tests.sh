# cd code
# COMMITHASH=`git rev-parse HEAD`
COMMITHASH=6ee54fbdeff88ca7ac770eb5ad61ec0850a1fd49
echo $COMMITHASH
# cd ..
# . conf/env.sh
export KUBECONFIG=/afs/cern.ch/user/d/dpetruk/backup_stuff/config
kubectl create namespace "commit-$COMMITHASH"
kubectl get pods --namespace="commit-$COMMITHASH"
kubectl apply -f kub/deps --validate=false --namespace="commit-$COMMITHASH"
sleep 10
kubectl apply -f kub/web --validate=false --namespace="commit-$COMMITHASH"
sleep 10
kubectl apply -f kub/tests --validate=false --namespace="commit-$COMMITHASH"
while ! kubectl --namespace=commit-$COMMITHASH get pods -a -o jsonpath='{.items[*].status.containerStatuses[0].state.terminated.exitCode}' | grep -q '^..*$'; do
    sleep 2
done
PODNAME=acceptance
echo `kubectl --namespace="commit-$COMMITHASH" get pods | grep 'acceptance' | awk '{print $1}'`
kubectl --namespace="commit-$COMMITHASH" get pods
EXITCODE=$(kubectl --namespace=commit-$COMMITHASH get pods -a -o jsonpath='{.items[*].status.containerStatuses[0].state.terminated.exitCode}')
echo "EXITCODE: $EXITCODE"
kubectl --namespace="commit-$COMMITHASH" logs $PODNAME


kubectl --namespace="commit-$COMMITHASH" delete -f kub/tests/
kubectl --namespace="commit-$COMMITHASH" delete -f kub/web
kubectl --namespace="commit-$COMMITHASH" delete -f kub/deps/
kubectl delete namespace "commit-$COMMITHASH"

cd ..
rm -rf folder-$COMMITHASH/

exit
