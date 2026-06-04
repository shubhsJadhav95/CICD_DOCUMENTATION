
# Start An EC2 instance as Ubuntu

# Install Java As Jenkin is Java Embedded

sudo apt update
sudo apt install openjdk-17-jre

java -version

# Install Debian package repo of jenkins

  sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian/jenkins.io-2026.key

# ADD jenkin apt repo entry

  echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
  
# Update local package index

  sudo apt-get update
  sudo apt-get install fontconfig openjdk-21-jre
  sudo apt-get install jenkins
  

# Admistrator Password 

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

sudo cat /var/lib/jenkins/secrets/initialAdminPassword


# Install An Suggested Plugins


# download an docker

sudo apt update
sudo apt install docker.io

# Grant jenkin user and Ubuntu user permission to docker deamon.

sudo su - 
usermod -aG docker jenkins
usermod -aG docker ubuntu
systemctl restart docker

sudo usermod -aG docker jenkins
sudo -u jenkins docker ps
groups jenkins

# Restart Jenkins

http://<ec2-instance-public-ip>:8080/restart
