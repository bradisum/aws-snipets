#!/bin/bash
# test

# download and install elastic search public signing key
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

# define the slasticsearch repository
echo "[elasticsearch-6.x] 
name=Elasticsearch repository for 6.x packages 
baseurl=https://artifacts.elastic.co/packages/6.x/yum 
gpgcheck=1 
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch 
enabled=1 
autorefresh=1 
type=rpm-md" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo > /dev/null

# update yum
sudo yum -y update

# install java
sudo yum -y install java-1.8.0-openjdk

# install elasticserach
sudo yum -y install elasticsearch

# start
sudo systemctl start elasticsearch

# add to boot
sudo systemctl enable elasticsearch
