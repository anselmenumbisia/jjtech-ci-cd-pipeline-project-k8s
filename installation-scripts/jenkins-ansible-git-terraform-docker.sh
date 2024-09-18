# #!/bin/bash
# # Hardware requirements: Amazon Linux 2 Kernel 5.10 AMI with mimum t2.medium type instance & port 8080(jenkins), 9100 (node-exporter) should be allowed on the security groups
# #Note: Dont use the latest EC2 Linux of 2023 as it doesnt have amazon-linux-extras which was used in the Jenkins installation as per the old AMI.
# # Installing Jenkins
# sudo yum update –y
# sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
# sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key # Note: Refer this link to change this key line frequently https://pkg.jenkins.io/redhat-stable/
# sudo yum upgrade
# sudo amazon-linux-extras install java-openjdk11 -y
# sudo yum install jenkins -y
# sudo echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# sudo systemctl enable jenkins
# sudo systemctl start jenkins

#!/bin/bash
# Ensure that your software packages are up to date on your instance by using the following command to perform a quick software update:
sudo yum update –y

# Add the Jenkins repo using the following command:
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo

#Import a key file from Jenkins-CI to enable installation from the package:
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

sudo yum upgrade

# Install Java (Amazon Linux 2023):
sudo dnf install java-17-amazon-corretto -y

sudo echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install Jenkins
sudo yum install jenkins -y

# Enable the Jenkins service to start at boot:
sudo systemctl enable jenkins

# Start Jenkins as a service:
sudo systemctl start jenkins

# You can check the status of the Jenkins service using the command:
sudo systemctl status jenkins

# Installing Git
sudo yum install git -y

# Installing maven - commented out as usage of tools explanation is required.
# sudo wget https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
# sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
# sudo yum install -y apache-maven

# installing Ansible

sudo dnf update
sudo dnf install python3.11 -y
sudo dnf install python3-pip -y
sudo pip install ansible
sudo useradd ansadmin
sudo sh -c 'echo "ansadmin:ansadmin" | chpasswd'
sudo mkdir -p /etc/ansible
sudo sh -c 'cat << EOF > /etc/ansible/ansible.cfg
$(cat ansible.cfg.template)
EOF'
sudo sed -i "s/.*#host_key_checking = False/host_key_checking = False/g" /etc/ansible/ansible.cfg
sudo sed -i "s/.*#enable_plugins = host_list, virtualbox, yaml, constructed/enable_plugins = aws_ec2/g" /etc/ansible/ansible.cfg


# ## Installing Ansible
# #sudo amazon-linux-extras install ansible2 -y
# sudo yum install python-pip -y
# sudo pip install boto3
# sudo pip install ansible
# sudo useradd ansadmin
# sudo echo ansadmin:ansadmin | chpasswd
# sudo sed -i "s/.*#host_key_checking = False/host_key_checking = False/g" /etc/ansible/ansible.cfg
# sudo sed -i "s/.*#enable_plugins = host_list, virtualbox, yaml, constructed/enable_plugins = aws_ec2/g" /etc/ansible/ansible.cfg
# sudo ansible-galaxy collection install amazon.aws

# Setup terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

# Install Docker
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker
sudo usermod -aG docker jenkins

# Install kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.25.9/2023-05-11/bin/linux/amd64/kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.25.9/2023-05-11/bin/linux/amd64/kubectl.sha256
sha256sum -c kubectl.sha256
openssl sha1 -sha256 kubectl
sudo chmod +x ./kubectl
sudo mkdir -p $HOME/bin && sudo cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
sudo echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
