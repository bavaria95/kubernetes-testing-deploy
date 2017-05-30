COMMITHASH=6ee54fbdeff88ca7ac770eb5ad61ec0850a1fd49
LOGIN=dpetruk
PASSWORD=PASSWORD
DOCKER_LOGIN=bavaria
KEYPAIR=desktop_linux

# python repo.py $COMMITHASH && \
# cp Dockerfile $COMMITHASH/ && \ # should be included to the repo itself
# cd $COMMITHASH && \
# docker build -t $DOCKER_LOGIN/inspire-base:$COMMITHASH . && \
# docker push $DOCKER_LOGIN/inspire-base:$COMMITHASH && \
# cd .. && \

# python cluster_create.py $LOGIN $PASSWORD cluster-$COMMITHASH $KEYPAIR && \

# mkdir conf/ && \
# mv ca.pem cert.pem config key.pem conf/ && \
# echo "export KUBECONFIG=~/$COMMITHASH/conf/config" > conf/env.sh && \
# cd .. && \

sed -i -e "s|image: bavaria/inspire-base|image: bavaria/inspire-base:$COMMITHASH|g" kub_config/*/*
cd .. && \
scp -rp folder-$COMMITHASH $LOGIN@lxplus-cloud.cern.ch:~/
cd folder-$COMMITHASH
OUTPUT=$(ssh -tt $LOGIN@lxplus-cloud.cern.ch < inside.sh)
echo $OUTPUT | grep -Po '&{80}\K(.*</testsuite>)' > output-$COMMITHASH.xml
echo "___________________________________________________________________"
echo $OUTPUT | grep -Po 'EXITCODE: \K(\d+)'
