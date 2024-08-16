#!/bin/bash

config_ans=~/.ansible.cfg

sudo apt update
sudo apt install ansible -y

echo "[defaults]" > $config_ans
echo "host_key_checking = False" >> $config_ans
echo "forks = 10" >> $config_ans

ansible-playbook -i hosts ansible-playbook-nginx.yml

ansible-playbook -i hosts ansible-playbook-prometheus.yml

ansible-playbook -i hosts ansible-playbook-exporters.yml

ansible-playbook -i hosts ansible-playbook-grafana.yml

ansible-playbook -i hosts ansible-playbook-elastic.yml

ansible-playbook -i hosts ansible-playbook-filebeat.yml

ansible-playbook -i hosts ansible-playbook-kibana.yml

