touch ok0.txt
# cd code
# COMMITHASH=`git rev-parse HEAD`
COMMITHASH=ec4bf0d5c99b9150fbb5445c41d22c929c11040a
echo $COMMITHASH
touch ok1.txt
# cd ..
# . conf/env.sh
export KUBECONFIG=/afs/cern.ch/user/d/dpetruk/config
touch ok2.txt
echo `kubectl get namespaces` > ns.txt
kubectl create namespace "commit-$COMMITHASH"
touch ok3.txt
kubectl get pods --namespace="commit-$COMMITHASH"
kubectl apply -f kub/deps --validate=false --namespace="commit-$COMMITHASH"
sleep 10
kubectl apply -f kub/web --validate=false --namespace="commit-$COMMITHASH"
sleep 10
kubectl apply -f kub/tests --validate=false --namespace="commit-$COMMITHASH"
touch ok4.txt
while ! kubectl --namespace=commit-$COMMITHASH get pods -a -o jsonpath='{.items[*].status.containerStatuses[0].state.terminated.exitCode}' | grep -q '^..*$'; do
    sleep 2
done
touch ok5.txt
PODNAME=acceptance
echo `kubectl --namespace="commit-$COMMITHASH" get pods | grep 'acceptance' | awk '{print $1}'`
kubectl --namespace="commit-$COMMITHASH" get pods
EXITCODE=$(kubectl --namespace=commit-$COMMITHASH get pods -a -o jsonpath='{.items[*].status.containerStatuses[0].state.terminated.exitCode}')
echo "EXITCODE: $EXITCODE"
kubectl --namespace="commit-$COMMITHASH" logs $PODNAME

touch ok6.txt

kubectl --namespace="commit-$COMMITHASH" delete -f kub/tests/
kubectl --namespace="commit-$COMMITHASH" delete -f kub/web
kubectl --namespace="commit-$COMMITHASH" delete -f kub/deps/
kubectl delete namespace "commit-$COMMITHASH"

cd ..
rm -rf folder-$COMMITHASH/

exit
