#!/bin/bash -x

# cd code
# COMMITHASH=`git rev-parse HEAD`
COMMITHASH=e5a697c762b1de3054103e25399aca7d051a3b1b
echo $COMMITHASH
echo `kubectl get namespaces` > ns.txt
kubectl create namespace "commit-$COMMITHASH"
kubectl get pods --namespace="commit-$COMMITHASH"
kubectl apply -f kub_config/deps --validate=false --namespace="commit-$COMMITHASH"
sleep 20
kubectl apply -f kub_config/web --validate=false --namespace="commit-$COMMITHASH"
sleep 20
kubectl apply -f kub_config/tests --validate=false --namespace="commit-$COMMITHASH"
sleep 10
while ! kubectl --namespace=commit-$COMMITHASH get pods -a -o jsonpath='{.items[*].status.containerStatuses[0].state.terminated.exitCode}' | grep -q '^..*$'; do
    sleep 2
done
PODNAME=acceptance
echo `kubectl --namespace="commit-$COMMITHASH" get pods | grep 'acceptance' | awk '{print $1}'`
kubectl --namespace="commit-$COMMITHASH" get pods
EXITCODE=$(kubectl --namespace=commit-$COMMITHASH get pods -a -o jsonpath='{.items[*].status.containerStatuses[0].state.terminated.exitCode}')
echo "EXITCODE: $EXITCODE"
kubectl --namespace="commit-$COMMITHASH" logs $PODNAME

kubectl --namespace="commit-$COMMITHASH" delete -f kub_config/tests/
kubectl --namespace="commit-$COMMITHASH" delete -f kub_config/web
kubectl --namespace="commit-$COMMITHASH" delete -f kub_config/deps/
kubectl delete namespace "commit-$COMMITHASH"

# cd ..
# rm -rf folder-$COMMITHASH/

exit
