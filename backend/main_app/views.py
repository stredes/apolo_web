from rest_framework import viewsets
from .models import MainApp
from .serializers import MainAppSerializer

class MainAppViewSet(viewsets.ModelViewSet):
    queryset = MainApp.objects.all()
    serializer_class = MainAppSerializer
