from rest_framework import serializers
from main_app.models import MainApp

class MainAppSerializer(serializers.ModelSerializer):
    class Meta:
        model = MainApp
        fields = '__all__'
