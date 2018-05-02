#!/bin/bash

set -x

internal_ip=$1

interfaces=$(ifconfig -a | perl /scripts/parse_ifconfig.pl "$internal_ip")
nat_interface=$(echo "$interfaces" | cut -d, -f 1)
internal_interface=$(echo "$interfaces" | cut -d, -f 2)

# DOCKER
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get install -y docker.io curl unzip virtualbox-guest-utils

# ROUTING/NAT
modprobe iptable_nat
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-ip_forward.conf
sudo mkdir /etc/iptables
INTERNAL_INTERFACE="$internal_interface" NAT_INTERFACE="$nat_interface" \
    envsubst '$NAT_INTERFACE $INTERNAL_INTERFACE' < files/iptables.envsubst.tpl > /etc/iptables/rules.v4
sudo apt-get install -y iptables-persistent

# DNSMASQ
INTERNAL_INTERFACE="$internal_interface" INTERNAL_IP="$internal_ip" \
    envsubst '$INTERNAL_IP $INTERNAL_INTERFACE' < files/dnsmasq.conf.envsubst.tpl > /etc/dnsmasq.conf
sudo cp files/dnsmasq.service /etc/systemd/system
sudo systemctl enable /etc/systemd/system/dnsmasq.service
sudo systemctl start dnsmasq.service

# MATCHBOX
sudo mkdir -p /etc/matchbox
sudo cp certs/* /etc/matchbox
sudo mkdir -p /var/lib/matchbox/scripts
sudo cp files/get-coreos /var/lib/matchbox/scripts
sudo /var/lib/matchbox/scripts/get-coreos stable 1688.5.3 /var/lib/matchbox/assets

sudo cp files/matchbox.service /etc/systemd/system
sudo systemctl enable /etc/systemd/system/matchbox.service
sudo systemctl start matchbox.service

# ubuntu user setup
sudo cp files/id_rsa* /home/ubuntu/.ssh
sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa*
sudo chmod 600 /home/ubuntu/.ssh/id_rsa
sudo usermod -G docker ubuntu

# TERRAFORM
temp_dir=$(mktemp -d)
curl --silent -L https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip -o "$temp_dir/terraform.zip"
curl --silent -L https://github.com/coreos/terraform-provider-matchbox/releases/download/v0.2.2/terraform-provider-matchbox-v0.2.2-linux-amd64.tar.gz -o "$temp_dir/terraform-provider-matchbox.tar.gz"
pushd "$temp_dir"
unzip terraform.zip
sudo cp terraform /usr/local/bin
tar xzvf terraform-provider-matchbox.tar.gz
sudo cp terraform-provider-matchbox-v0.2.2-linux-amd64/terraform-provider-matchbox /usr/local/bin
popd
sudo rm -rf "$temp_dir"
sudo mkdir -p /home/ubuntu/.matchbox/infra-local
sudo cp certs/* /home/ubuntu/.matchbox/infra-local
sudo chown -R ubuntu:ubuntu /home/ubuntu/terraform

# SERVICES CHECK
for service in matchbox dnsmasq; do
    systemctl is-active "${service}.service" > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        cat <<EOF
Service $service is NOT active. Try starting it using:

systemctl start ${service}.service

EOF
    fi
done