#!/bin/bash -x

COMMITHASH=e5a697c762b1de3054103e25399aca7d051a3b1b

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

echo $OUTPUT > out.txt

echo $OUTPUT | grep -Po '(<\?xml version=.*</testsuite>)' > result.xml && \
# echo "___________________________________________________________________" && \
EXITCODE=$(echo $OUTPUT | grep -Po 'EXITCODE: \K(\d+)')
exit $EXITCODE
