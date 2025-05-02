from etiquetas.views import print_label
from informes.views import ClienteViewSet
from informes.views import MainAppViewSet
from django.contrib import admin
from django.urls import include, path
from rest_framework import routers
from informes.views import ClienteViewSet
from etiquetas.views import print_label

router = routers.DefaultRouter()
    router.register("clientes", ClienteViewSet, basename="clientes")
    router.register('clientes', ClienteViewSet, basename='clientes')
    router.register('clientes', ClienteViewSet, basename='clientes')
    router.register('clientes', ClienteViewSet, basename='clientes')
    router.register('clientes', ClienteViewSet, basename='clientes')

urlpatterns = [
    path("api/etiquetas/print/", print_label),
path('admin/', admin.site.urls),
path('api/', include(router.urls)),
path('api/etiquetas/print/', print_label),
]
