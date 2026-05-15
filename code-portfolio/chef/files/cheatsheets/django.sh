# Django Shell Access
python manage.py shell                      # Open Django shell

# User Management
python manage.py createsuperuser            # Create a superuser

# Database Management
python manage.py makemigrations             # Create migrations for changes
python manage.py migrate                    # Apply migrations

# Application Health Check
python manage.py check                      # Check for potential issues

# Server Operations
gunicorn your_project_name.wsgi:application \
  -b unix:/path/to/your/socket.sock --access-logfile - # Run gunicorn in foreground

# Development Debugging with ipdb
# 1. Install ipdb to server_env
# 2. Add to code: "import ipdb; ipdb.set_trace()"
# 3. Use quick-build.sh or make -C server_api install (does not overwrite ipdb)
# 4. SSH into server and stop Django:
vagrant ssh bootstrap
sudo su -l
systemctl stop django

# 5. Start gunicorn with increased timeout
/opt/vmass/server_api/server_env/bin/gunicorn --workers 3 \
  --bind unix:/var/run/api_v1.sock api_v1.wsgi:application --timeout 3600

# API Testing
curl -L localhost/api/cap/messages/        # Test API endpoint
