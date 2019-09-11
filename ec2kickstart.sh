#!/bin/bash


ssh awsprv <<'END'
sudo yum update -y
sudo yum -y install git
git clone https://github.com/bradisum/aws-snipets.git
cd aws-snipets
chmod a+x *.sh
./esconfig.sh
END


ssh awsbas <<'END'
sudo yum -y update
sudo yum -y install git
git clone https://github.com/bradisum/aws-snipets.git
cd aws-snipets
chmod a+x *.sh
./lsconfig.sh 10.0.1.52
./kbconfig.sh 10.0.1.52
END


# installing certbot to install a cert for 
# sudo yum install certbot python2-certbot-apache mod_ssl

# request a cert (stop anything listening on port 80 first)
# sudo certbot certonly --standalone -d log2.giftbot.io

# copy the certs from 
# /etc/letsencrypt/live/<domain>/cert.pem / fullchain.pem / privkey.pem towhere it needs to do.

# sample http input wiht ssl  possibly dont need cors issue.
# input {
#   http {
#     host => "0.0.0.0"
#     port => 31311
#     ssl => true
#     ssl_certificate => "/etc/logstash/conf.d/fullchain.pem"
#     ssl_key => "/etc/logstash/conf.d/privkey.pem"
#     response_headers => {
#         "Access-Control-Allow-Origin" => "*"
#                 "Content-Type" => "text/plain"
#                 "Access-Control-Allow-Headers" => "Origin, X-Requested-With, Content-Type, Accept"
#         }

#   }
# }


# kick off a log message
 # curl -XPUT 'http://ec2-100-26-199-243.compute-1.amazonaws.com:31311/sample/message/1' -d 'hello'



