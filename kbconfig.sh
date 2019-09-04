#!/bin/bash

ESHOST=${1:-localhost}
X="abc123"


# define the slasticsearch repository
echo "[elasticsearch-6.x] 
name=Elasticsearch repository for 6.x packages 
baseurl=https://artifacts.elastic.co/packages/6.x/yum 
gpgcheck=1 
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch 
enabled=1 
autorefresh=1 
type=rpm-md" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo > /dev/null

sudo yum -y update 

# install elasticserach
sudo yum -y install kibana

# write kabana config
echo "

# set the elastic search host
elasticsearch.hosts: [\"http://$ESHOST:9200\"]

" | sudo tee /etc/kibana/kibana.yml

# start and enable on boot
sudo systemctl start kibana
sudo systemctl enable kibana

# required for nginx
sudo amazon-linux-extras install epel -y

# install nginx for reverse proxy
sudo yum -y install nginx

# start and add to boot
sudo systemctl start nginx
sudo systemctl enable nginx

# generate basic password
echo "admin:`openssl passwd -apr1 $X`" | sudo tee /etc/nginx/htpasswd.users

# define nginx server
echo "server {
    listen 80;

    server_name *.amazonaws.com;

    auth_basic \"Restricted Access\";
    auth_basic_user_file /etc/nginx/htpasswd.users;

    location / {
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}" | sudo tee /etc/nginx/conf.d/gslogs.com.conf


sudo systemctl restart nginx

sudo setsebool httpd_can_network_connect 1 -P
