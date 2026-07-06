#!/bin/bash

set -e

sudo apt-get update -y

sudo apt-get install -y \
  curl \
  wget \
  unzip \
  gnupg \
  software-properties-common \
  apt-transport-https \
  ca-certificates

# ---------- Docker ----------
sudo apt-get update
sudo apt install docker.io
docker ps
sudo chown $USER /var/run/docker.sock   # jenkins user may not exist yet at this point

docker ps

# ---------- Jenkins ----------

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
 https://pkg.jenkins.io/debian/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
  

sudo apt-get update -y
sudo apt-get install -y fontconfig openjdk-21-jre
sudo apt-get install -y jenkins

# add jenkins user to docker group now that it exists
sudo usermod -aG docker jenkins

# ---------- Trivy ----------
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | \
  sudo tee /etc/apt/sources.list.d/trivy.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y trivy

# ---------- AWS CLI v2 ----------
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt-get install -y unzip
unzip -o awscliv2.zip
sudo ./aws/install -i /usr/local/aws-cli -b /usr/local/bin --update



# ---------- SonarQube ----------
docker run -d --name sonar --restart unless-stopped -p 9000:9000 sonarqube:lts-community


# Add Docker to an Jenkins
getent group docker
sudo usermod -aG docker jenkins
groups jenkins

# Jenkins Password

sudo cat /var/lib/jenkins/secrets/initialAdminPassword