from django.views.generic import TemplateView
from django.contrib import admin
from django.urls import path, include
from django.shortcuts import redirect
from rest_framework import routers
from informes.views import ClienteViewSet

try:
    from informes.views import MainAppViewSet
except ImportError:
    MainAppViewSet = None

router = routers.DefaultRouter()
router.register('clientes', ClienteViewSet, basename='clientes')
if MainAppViewSet:
    router.register('main_app', MainAppViewSet, basename='main_app')

urlpatterns = [
    path('', TemplateView.as_view(template_name='index.html'), name='spa-root'),
    path('', lambda req: redirect('api/', permanent=False)),
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
]
