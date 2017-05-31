touch f1.txt
COMMITHASH=ec4bf0d5c99b9150fbb5445c41d22c929c11040a
touch f2.txt
cd folder-$COMMITHASH;
touch f3.txt
chmod u+x tests.sh;
touch f4.txt
./tests.sh;
touch f5.txt
exit 0;
