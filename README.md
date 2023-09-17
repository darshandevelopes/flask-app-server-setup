# Flask App Server Setup Script

This Bash script is designed to automate the initial setup of a server for hosting a Flask web application with Gunicorn and Nginx. It performs the following tasks:

1. Updates the system and installs necessary software.
2. Takes input for the Flask app directory name and Git repository URL.
3. Copies files from the Git repository folder to the Flask app directory.
4. Sets up a Python virtual environment and installs dependencies.
5. Creates a WSGI entry point file.
6. Sets up a Gunicorn systemd service.
7. Configures Nginx to serve the Flask app.
8. Starts Gunicorn and Nginx service.

## Requirements

- Ubuntu 22.04
- Port 80 open to all internet traffic
- Flask app's entry point named app.py
- Flask app's requirements.txt includes 'wheel', 'gunicorn', and 'flask'


## Usage

1. Ensure You Have a Git Repository for Your Flask App ([Example](https://github.com/darshandevelopes/flask-hello-world.git))

2. Make the script executable:
   ```bash
   chmod +x setup.sh

3. Run the script:
   ```bash
   ./setup.sh
   
4. Follow the prompts and provide the required information when prompted.


## Notes

- The script is designed for Ubuntu 22.04 but can be adapted for other Linux distributions.
- You may need to configure your domain's DNS settings to point to your server's IP address for proper domain resolution.
- The firewall setup (UFW) is commented out by default. Uncomment and configure it as needed for your specific security requirements.
- Ensure you have the necessary permissions to run the script and perform system-level tasks.
- Back up important data before running the script, as it makes significant changes to your system configuration.
- Review the script carefully and test it in a controlled environment before using it on a production server.

## Debug
If you encounter any errors, trying checking the following:

Check the Nginx error logs
```bash
sudo less /var/log/nginx/error.log
```
Check the Nginx access logs
```bash
sudo less /var/log/nginx/access.log
```
Check the Nginx process logs
```bash
sudo journalctl -u nginx
```
Checks your Flask app’s Gunicorn logs.
```bash
sudo journalctl -u flask_app_dir
```
## Extra - Secure your Flask app with an SSL certificate
```bash
sudo apt install python3-certbot-nginx
sudo certbot --nginx -d your_domain -d www.your_domain
```
## Disclaimer
Use this script at your own risk. The script is provided as-is, and the authors are not responsible for any issues or data loss that may occur as a result of its use.
