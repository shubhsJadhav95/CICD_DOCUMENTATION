#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

sudo apt update -y
sudo apt upgrade -y

sudo apt install -y \
  curl \
  wget \
  unzip \
  gnupg \
  software-properties-common \
  apt-transport-https \
  ca-certificates

sudo apt install prometheus -y
sudo systemctl enable prometheus
sudo systemctl start prometheus

wget -q -O - https://apt.grafana.com/gpg.key | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/grafana.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/grafana.gpg] https://apt.grafana.com stable main" | \
  sudo tee /etc/apt/sources.list.d/grafana.list > /dev/null

sudo apt update -y
sudo apt install grafana -y
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker ubuntu
sudo chmod 666 /var/run/docker.sock

docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
  https://aquasecurity.github.io/trivy-repo/deb generic main" | \
  sudo tee /etc/apt/sources.list.d/trivy.list > /dev/null

sudo apt update -y
sudo apt install trivy -y

sudo apt install -y fontconfig openjdk-17-jre

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
          https://pkg.jenkins.io/debian/jenkins.io-2026.key

  echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
  

sudo apt update -y
sudo apt install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

IP=$(curl -s ifconfig.me)

echo "==================================="
echo "SonarQube  : http://$IP:9000"
echo "Grafana    : http://$IP:3000"
echo "Prometheus : http://$IP:9090"
echo "Jenkins    : http://$IP:8080"
echo "==================================="
