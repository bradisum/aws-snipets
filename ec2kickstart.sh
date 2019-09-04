#!/bin/bash


ssh awsprv <<'END'
sudo yum update;
git clone https://github.com/bradisum/aws-snipets.git;
cd aws-snipets
./esconfig.sh"
END


ssh awsbas <<'END'
sudo yum -y update
sudo yum -y install git
git clone https://github.com/bradisum/aws-snipets.git
cd aws-snipets
chmod a+x *.sh
./lsconfig.sh 10.0.1.131
./kbconfig.sh 10.0.1.131
END


# kick off a log message
 # curl -XPUT 'http://ec2-100-26-199-243.compute-1.amazonaws.com:31311/sample/message/1' -d 'hello'



