from rest_framework import viewsets
from .models import _Init_
from .serializers import _Init_Serializer

class _Init_ViewSet(viewsets.ModelViewSet):
    queryset = _Init_.objects.all()
    serializer_class = _Init_Serializer
