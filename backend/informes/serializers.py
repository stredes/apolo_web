from rest_framework import serializers
from .models import MainAppModel
from .models import Cliente

class ClienteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Cliente
        fields = '__all__'

class MainAppSerializer(serializers.ModelSerializer):
    class Meta:
        model = MainAppModel
        fields = '__all__'
