from rest_framework import serializers
from __init__.models import _Init_

class _Init_Serializer(serializers.ModelSerializer):
    class Meta:
        model = _Init_
        fields = '__all__'
