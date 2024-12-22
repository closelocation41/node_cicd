#!/bin/bash

# Script to install Node.js and set up a Node.js application

echo "Updating package index..."
sudo apt update -y

echo "Installing Node.js..."
# Add Node.js PPA
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

echo "Installing build-essential for compiling native add-ons..."
sudo apt install -y build-essential

echo "Checking Node.js and npm versions..."
node -v
npm -v

echo "Setting up the Node.js application..."
# Replace with the desired directory and application repository
APP_DIR="/var/www/my-node-app"
GIT_REPO="https://github.com/username/repository.git"

if [ ! -d "$APP_DIR" ]; then
  echo "Cloning the Node.js application repository..."
  sudo git clone "$GIT_REPO" "$APP_DIR"
else
  echo "Directory $APP_DIR already exists. Skipping clone."
fi

cd "$APP_DIR"

echo "Installing application dependencies..."
npm install

echo "Configuring the Node.js application to run as a service..."
SERVICE_FILE="/etc/systemd/system/my-node-app.service"

sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=My Node.js Application
After=network.target

[Service]
Environment=PORT=8000
Type=simple
User=$(whoami)
WorkingDirectory=$APP_DIR
ExecStart=$(which node) $APP_DIR/server.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Starting the Node.js application service..."
sudo systemctl start my-node-app

echo "Enabling the service to start on boot..."
sudo systemctl enable my-node-app

echo "Setup completed. Application is running."

# Display server IP and port
PUBLIC_IP=$(hostname -I | awk '{print $1}')
echo "Access the Node.js application at: http://$PUBLIC_IP:8000"
