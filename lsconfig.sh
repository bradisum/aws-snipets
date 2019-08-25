#!/bin/bash

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
type=rpm-md" | sudo tee /etc/yum.repos.d/elasticsearch.repo > /dev/null

# update yum
sudo yum -y update

# install java
sudo yum -y install java-1.8.0-openjdk

# install java
sudo yum -y install logstash

echo "input {
  http {
    host => \"0.0.0.0\" # default: 0.0.0.0
    port => 31311 # default: 8080
  }
}" | sudo tee /etc/logstash/conf.d/02-http-input.conf > /dev/null


echo "input {
  beats {
    port => 5044
  }
}" | sudo tee /etc/logstash/conf.d/03-beats-input.conf > /dev/null



echo "filter {
  if [fileset][module] == \"system\" {
    if [fileset][name] == \"auth\" {
      grok {
        match => { \"message\" => [\"%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} sshd(?:\[%{POSINT:[system][auth][pid]}\])?: %{DATA:[system][auth][ssh][event]} %{DATA:[system][auth][ssh][method]} for (invalid user )?%{DATA:[system][auth][user]} from %{IPORHOST:[system][auth][ssh][ip]} port %{NUMBER:[system][auth][ssh][port]} ssh2(: %{GREEDYDATA:[system][auth][ssh][signature]})?\",
                  \"%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} sshd(?:\[%{POSINT:[system][auth][pid]}\])?: %{DATA:[system][auth][ssh][event]} user %{DATA:[system][auth][user]} from %{IPORHOST:[system][auth][ssh][ip]}\",
                  \"%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} sshd(?:\[%{POSINT:[system][auth][pid]}\])?: Did not receive identification string from %{IPORHOST:[system][auth][ssh][dropped_ip]}\",
                  \"%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} sudo(?:\[%{POSINT:[system][auth][pid]}\])?: \s*%{DATA:[system][auth][user]} :( %{DATA:[system][auth][sudo][error]} ;)? TTY=%{DATA:[system][auth][sudo][tty]} ; PWD=%{DATA:[system][auth][sudo][pwd]} ; USER=%{DATA:[system][auth][sudo][user]} ; COMMAND=%{GREEDYDATA:[system][auth][sudo][command]}\",
                  \"%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} groupadd(?:\[%{POSINT:[system][auth][pid]}\])?: new group: name=%{DATA:system.auth.groupadd.name}, GID=%{NUMBER:system.auth.groupadd.gid}\",
                  \"%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} useradd(?:\[%{POSINT:[system][auth][pid]}\])?: new user: name=%{DATA:[system][auth][user][add][name]}, UID=%{NUMBER:[system][auth][user][add][uid]}, GID=%{NUMBER:[system][auth][user][add][gid]}, home=%{DATA:[system][auth][user][add][home]}, shell=%{DATA:[system][auth][user][add][shell]}$\",
                  \"%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} %{DATA:[system][auth][program]}(?:\[%{POSINT:[system][auth][pid]}\])?: %{GREEDYMULTILINE:[system][auth][message]}\"] }
        pattern_definitions => {
          \"GREEDYMULTILINE\"=> \"(.|\n)*\"
        }
        remove_field => \"message\"
      }
      date {
        match => [ \"[system][auth][timestamp]\", \"MMM  d HH:mm:ss\", \"MMM dd HH:mm:ss\" ]
      }
      geoip {
        source => \"[system][auth][ssh][ip]\"
        target => \"[system][auth][ssh][geoip]\"
      }
    }
    else if [fileset][name] == \"syslog\" {
      grok {
        match => { \"message\" => [\"%{SYSLOGTIMESTAMP:[system][syslog][timestamp]} %{SYSLOGHOST:[system][syslog][hostname]} %{DATA:[system][syslog][program]}(?:\[%{POSINT:[system][syslog][pid]}\])?: %{GREEDYMULTILINE:[system][syslog][message]}\"] }
        pattern_definitions => { \"GREEDYMULTILINE\" => \"(.|\n)*\" }
        remove_field => \"message\"
      }
      date {
        match => [ \"[system][syslog][timestamp]\", \"MMM  d HH:mm:ss\", \"MMM dd HH:mm:ss\" ]
      }
    }
  }
}
" | sudo tee /etc/logstash/conf.d/10-syslog.conf > /dev/null

echo "output {
  elasticsearch {
    hosts => [\"localhost:9200\"]
    manage_template => false
    index => \"%{[@metadata][type]}-%{[@metadata][version]}-%{+YYYY.MM.dd}\"
  }
}" | sudo tee /etc/logstash/conf.d/30-elasticsearch-output.conf > /dev/null

# start
sudo systemctl start logstash

# add to boot
sudo systemctl enable logstash
