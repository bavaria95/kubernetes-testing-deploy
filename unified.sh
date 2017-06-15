set -x

COMMITHASH=somenewcommitinpr
REPO=gitlab-registry.cern.ch/dpetruk/kubernetes-testing-deploy/inspire-base

echo $BUILD_TAG

sed -i -e "s|image: bavaria/inspire-base|image: $REPO:$COMMITHASH|g" kubernetes-testing-deploy/kub_config/*/*

kubectl create namespace "commit-$COMMITHASH"
kubectl get pods --namespace="commit-$COMMITHASH"
kubectl apply -f kubernetes-testing-deploy/kub_config/deps --validate=false --namespace="commit-$COMMITHASH"
sleep 20
kubectl apply -f kubernetes-testing-deploy/kub_config/web --validate=false --namespace="commit-$COMMITHASH"
sleep 20
kubectl apply -f kubernetes-testing-deploy/kub_config/tests --validate=false --namespace="commit-$COMMITHASH"
sleep 10
while ! kubectl --namespace=commit-$COMMITHASH get pods -a -o jsonpath='{.items[*].status.containerStatuses[0].state.terminated.exitCode}' | grep -q '^..*$'; do
    sleep 2
done

PODNAME=acceptance
kubectl --namespace="commit-$COMMITHASH" get pods
OUTPUT=$(kubectl --namespace="commit-$COMMITHASH" logs $PODNAME)
EXITCODE=$(kubectl --namespace=commit-$COMMITHASH get pods -a -o jsonpath='{.items[*].status.containerStatuses[0].state.terminated.exitCode}')
kubectl get ns
echo "EXITCODE"
echo $EXITCODE
echo "________________________________________"
echo $OUTPUT

kubectl --namespace="commit-$COMMITHASH" delete -f kubernetes-testing-deploy/kub_config/tests/
kubectl --namespace="commit-$COMMITHASH" delete -f kubernetes-testing-deploy/kub_config/web
kubectl --namespace="commit-$COMMITHASH" delete -f kubernetes-testing-deploy/kub_config/deps/
kubectl delete namespace "commit-$COMMITHASH"

echo $OUTPUT | grep -Po '(<\?xml version=.*</testsuite>)' > result.xml
cat result.xml
exit $EXITCODE
