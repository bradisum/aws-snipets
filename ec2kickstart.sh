#!/bin/bash

sudo yum -y install git

git clone https://github.com/bradisum/aws-snipets.git

chmod a+x aws-snipets/*.sh


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
END


ssh awsbas <<'END'
sudo yum -y update
sudo yum -y install git
git clone https://github.com/bradisum/aws-snipets.git
cd aws-snipets
chmod a+x *.sh
./kbconfig.sh
END
