#!/bin/bash

cat <<EOF
################
# System: Ubuntu 22.04
# Port 80 is open to all internet traffic
# Ensure that Flask app's entry point is named app.py
# Ensure that your app's requirements.txt includes 'wheel', 'gunicorn', and 'flask'
################
EOF

# Ask the user to confirm
read -p "Press 'y' to continue or 'n' to abort: " user_input

# Check user's response
[[ "$user_input" != "y" ]] && echo "Aborting the script." && exit 1

# Detect the current user
current_user=$(whoami)

# Update the system
sudo apt update
sudo apt upgrade -y

# Install required software
sudo apt install -y python3-pip python3-venv nginx

# Take input for the Flask app directory name
read -p "Enter the directory name for your Flask app: " flask_app_dir

# Create a directory for your Flask app
mkdir ~/"$flask_app_dir"
cd ~/"$flask_app_dir"

# Take input for the Flask app repository
read -p "Enter the repository url. (ex: https://github.com/yourusername/yourflaskapp.git): " git_url
git clone "$git_url"

# Extract the repository name from the Git URL
git_folder_name=$(basename "$git_url" .git)
cd "$git_folder_name"

# Copy all files from the Git repository folder to the Flask app directory
cp -r * ~/"$flask_app_dir"

# Delete the Git repository folder 
cd ~/"$flask_app_dir"
rm -rf "$git_folder_name"

# Set up a Python virtual environment and install dependencies
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create a WSGI entry point file
cat <<EOF | sudo tee ~/"$flask_app_dir"/wsgi.py
from app import app

if __name__ == "__main__":
    app.run()
EOF



# Create a Gunicorn systemd service
cat <<EOF | sudo tee /etc/systemd/system/"$flask_app_dir".service
[Unit]
Description=Gunicorn instance to serve my Flask App
After=network.target

[Service]
User=$current_user
Group=www-data
WorkingDirectory=/home/$current_user/$flask_app_dir
Environment="PATH=/home/$current_user/$flask_app_dir/venv/bin"
ExecStart=/home/$current_user/$flask_app_dir/venv/bin/gunicorn --workers 3 --bind unix:/home/$current_user/$flask_app_dir/$flask_app_dir.sock -m 007 wsgi:app

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the Gunicorn service
sudo systemctl start "$flask_app_dir"
sudo systemctl enable "$flask_app_dir"

# Configure Nginx
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default

# Take input for the domain name
read -p "Enter your domain name (ex: example.com): " domain_name

cat <<EOF | sudo tee /etc/nginx/sites-available/"$flask_app_dir"
server {
    listen 80;
    server_name $domain_name www.$domain_name;

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/$current_user/$flask_app_dir/$flask_app_dir.sock;
    }
}
EOF

# Make user’s home directory allow other users to access files inside it. So that Nginx can access the sock file.
sudo chmod 755 /home/"$current_user"

sudo ln -s /etc/nginx/sites-available/"$flask_app_dir" /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Set up firewall rules (allow Nginx)
# sudo ufw allow 'Nginx Full'

# Enable the firewall
# sudo ufw --force enable

# You may need to configure your domain's DNS settings to point to your server's IP address.

echo "The initial server setup is complete. Your Flask app should now be running with Gunicorn and Nginx."
