#!/bin/bash

# Variables
NEXUS_VERSION="3.74.0-01"  # Nexus version to install
NEXUS_DATA_DIR="/data/nexus-data"  # Custom Nexus data directory

# Update system packages
echo "Updating system packages..."
sudo dnf update -y

# Install Java 11 (required for Nexus 3.74.0)
echo "Installing Java 11..."
sudo dnf install -y java-11-openjdk

# Create a user for Nexus without login privileges
echo "Creating nexus user..."
sudo useradd -M -d /tmp/nexus -s /bin/nologin nexus

# Download Nexus Repository OSS version 3.74.0
echo "Downloading Nexus Repository..."
cd /tmp
wget https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz

# Extract Nexus to /opt directory
echo "Extracting Nexus..."
sudo tar -zxvf nexus-${NEXUS_VERSION}-unix.tar.gz -C /opt
sudo mv /tmp/nexus-${NEXUS_VERSION} /tmp/nexus

# Create custom data directory
echo "Creating custom data directory at ${NEXUS_DATA_DIR}..."
sudo mkdir -p ${NEXUS_DATA_DIR}
sudo chown -R nexus:nexus ${NEXUS_DATA_DIR}

# Configure Nexus to use custom data directory
echo "Configuring Nexus to use custom data directory..."
echo "-Dkaraf.data=${NEXUS_DATA_DIR}" | sudo tee -a /tmp/nexus/bin/nexus.vmoptions

# Set permissions for nexus user
echo "Setting permissions for Nexus directories..."
sudo chown -R nexus:nexus /tmp/nexus
sudo chown -R nexus:nexus /tmp/sonatype-work

# Configure Nexus to run as a systemd service
echo "Configuring Nexus as a systemd service..."
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

# Set Nexus to start on boot and enable the service
echo "Enabling and starting Nexus service..."
sudo systemctl enable nexus
sudo systemctl start nexus

# Check the status of Nexus
echo "Checking Nexus status..."
sudo systemctl status nexus

# Print Nexus URL for user access
echo "Nexus Repository Manager 3.74.0 is installed and running."
echo "Access it at: http://<your_server_ip>:8081"

# Cleanup downloaded files
rm /tmp/nexus-${NEXUS_VERSION}-unix.tar.gz
