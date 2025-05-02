from .serializers import ClienteSerializer
from rest_framework import viewsets
from informes.models import Cliente
from informes.serializers import ClienteSerializer

class ClienteViewSet(viewsets.ModelViewSet):
    serializer_class = ClienteSerializer
    queryset = Cliente.objects.all()
    serializer_class = ClienteSerializer

from rest_framework import viewsets
from .models import MainAppModel  # <– ajusta al modelo real
from .serializers import MainAppSerializer  # <– ajusta al serializer real

class MainAppViewSet(viewsets.ModelViewSet):
    queryset = MainAppModel.objects.all()
    serializer_class = MainAppSerializer
