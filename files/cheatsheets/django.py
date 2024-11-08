# django.py Cheatsheet

# Django Administration Cheatsheet

# --- Models and Database Operations ---
# Querying Data
from myapp.models import MyModel
objects = MyModel.objects.all()                    # Retrieve all records
filtered_objects = MyModel.objects.filter(attribute='value')  # Filtered query

# Creating Objects
new_object = MyModel(attribute='value')            # New instance
new_object.save()                                  # Save to database

# Updating Objects
obj = MyModel.objects.get(id=1)                    # Retrieve by ID
obj.attribute = 'new value'                        # Update attribute
obj.save()                                         # Save changes

# Deleting Objects
obj = MyModel.objects.get(id=1)                    # Retrieve by ID
obj.delete()                                       # Delete object

# Additional Querying Techniques
Entry.objects.all()[:5]                            # First 5 objects
Entry.objects.all()[5:10]                          # Objects 6-10
Entry.objects.all()[:10:2]                         # First 10, every second

# Single Record Retrieval
Entry.objects.order_by('headline')[0]              # First ordered record
Entry.objects.order_by('headline')[0:1].get()      # Safer single retrieval

# Field Lookup and Joins
Entry.objects.filter(field='value')                # Simple field filter
Entry.objects.filter(blog__name='Beatles Blog')    # ForeignKey filter
Blog.objects.filter(entry__headline__contains='Lennon') # Reverse join
Blog.objects.filter(entry__authors__name__isnull=True)  # Filter by relation

# --- Django Admin Customization ---
from django.contrib import admin
from .models import MyModel

@admin.register(MyModel)
class MyModelAdmin(admin.ModelAdmin):
    list_display = ('attribute', 'other_attribute') # Display settings

# --- Debugging ---
import logging
logger = logging.getLogger(__name__)

def my_view(request):
    logger.debug('A debug message!')               # Log debug message

# --- Gunicorn & Deployment ---
# Run in Foreground
gunicorn your_project_name.wsgi:application -b unix:/path/to/your/socket.sock --access-logfile -

# Run via Systemd and Vagrant
# Build and Test Steps
# 1. Install ipdb to server_env
# 2. Add code: "import ipdb; ipdb.set_trace()"
# 3. Use quick-build.sh or make -C server_api install (does not overwrite ipdb)
# 4. Connect:
vagrant ssh bootstrap
sudo su -l
systemctl stop django;
  /opt/vmass/server_api/server_env/bin/gunicorn --workers 3 --bind unix:/var/run/api_v1.sock api_v1.wsgi:application --timeout 3600

# 5. API Test Request
curl -L localhost/api/cap/messages/

# --- Sample Code ---
# API View: OrderedDicts and Tuples
from rest_framework import generics

class CapsListView(generics.ListAPIView):
    def list_ids(self, request, *args, **kwargs):
        res = super().list(self, request, args, kwargs)
        item = res.data.popitem()
        for message in item[1]:
            print(message['id'])                  # Print message IDs

# Django REST Framework: ListAPIView and Generics
# Docs: https://www.django-rest-framework.org/api-guide/generic-views/

# --- Quick Model Operations ---
# Retrieve Single / Multiple Records
Model.get()                                        # Retrieve one record
Model.filter()                                     # Retrieve multiple records
