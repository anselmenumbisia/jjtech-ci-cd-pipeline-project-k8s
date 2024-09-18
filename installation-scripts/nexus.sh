#!/bin/bash

# Update system packages
yum update -y

# Install Java 11 (required for Nexus)
amazon-linux-extras enable corretto8
yum install java-11-amazon-corretto -y

# Create a nexus user
useradd nexus
echo "nexus  ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

# Download Nexus
cd /opt
wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz

# Extract Nexus
tar -zxvf latest-unix.tar.gz
mv nexus-* nexus
chown -R nexus:nexus /opt/nexus
chown -R nexus:nexus /opt/sonatype-work

# Create a nexus service
cat <<EOF > /etc/systemd/system/nexus.service
[Unit]
Description=Nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# Set run as nexus user in Nexus configuration
sed -i 's/#run_as_user=""/run_as_user="nexus"/' /opt/nexus/bin/nexus.rc

# Enable and start the Nexus service
systemctl enable nexus
systemctl start nexus

# Open firewall for Nexus (port 8081)
firewall-cmd --zone=public --add-port=8081/tcp --permanent
firewall-cmd --reload

# Check Nexus status
systemctl status nexus
