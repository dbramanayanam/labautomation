#!/bin/bash

# Update the system
echo "Updating system packages..."
sudo dnf update -y

# Install Java (Nexus requires Java 8 or higher)
echo "Installing Java..."
sudo dnf install java-11-openjdk -y

# Create a user for Nexus
echo "Creating nexus user..."
sudo useradd -M -d /opt/nexus -s /bin/bash nexus

# Download Nexus Repository OSS version 3.74.0
echo "Downloading Nexus Repository..."
cd /tmp
NEXUS_VERSION="3.74.0-01"  # Version specified
wget https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz

# Extract Nexus to /opt directory
echo "Extracting Nexus..."
sudo tar -zxvf nexus-${NEXUS_VERSION}-unix.tar.gz -C /opt
sudo mv /opt/nexus-${NEXUS_VERSION} /opt/nexus

# Set permissions
echo "Setting permissions for Nexus..."
sudo chown -R nexus:nexus /opt/nexus
sudo chown -R nexus:nexus /opt/sonatype-work

# Configure Nexus to run as a service
echo "Configuring Nexus as a service..."
sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOL
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the Nexus service
echo "Enabling and starting Nexus service..."
sudo systemctl enable nexus
sudo systemctl start nexus

# Check the status of Nexus
echo "Checking Nexus status..."
sudo systemctl status nexus

# Print the Nexus URL
echo "Nexus Repository Manager is installed and running."
echo "Access it at: http://<your_server_ip>:8081"

# Cleanup
rm /tmp/nexus-${NEXUS_VERSION}-unix.tar.gz
