#!/bin/bash -x

COMMITHASH=ec4bf0d5c99b9150fbb5445c41d22c929c11040a

git clone https://github.com/inspirehep/inspire-next.git $COMMITHASH && \
cd $COMMITHASH && \
git checkout $COMMITHASH && \
# python repo.py $COMMITHASH && \
cd .. && \
ls && \
cp Dockerfile $COMMITHASH/ && \
echo "copied dockerfile" && \
cd $COMMITHASH && \
ls && \
docker login -u $DOCKER_LOGIN -p $DOCKER_PASSWORD
docker build -t $DOCKER_LOGIN/inspire-base:$COMMITHASH . && \
docker push $DOCKER_LOGIN/inspire-base:$COMMITHASH && \
cd .. && \

ls && \
sed -i -e "s|image: bavaria/inspire-base|image: bavaria/inspire-base:$COMMITHASH|g" kub_config/*/* && \
FOLDER=${PWD##*/}
cd .. && \
echo $PASSWORD | kinit $LOGIN@CERN.CH && \
echo "after kinit" && \
ls && \
cd $FOLDER && \
# OUTPUT=$(ssh -tt $LOGIN@lxplus-cloud.cern.ch < inside.sh) && \
OUTPUT=$(./tests.sh) && \

echo $OUTPUT | grep -Po '&{80}\K(.*</testsuite>)' > output-$COMMITHASH.xml && \
echo "___________________________________________________________________" && \
echo $OUTPUT | grep -Po 'EXITCODE: \K(\d+)'
