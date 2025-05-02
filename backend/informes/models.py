from django.db import models

class Cliente(models.Model):
    nombre = models.CharField(max_length=200)
    direccion = models.CharField(max_length=300)
    ruc = models.CharField(max_length=20, unique=True)

    def __str__(self):
        return self.nombre

# ——— Stub MainAppModel (genera tus campos reales aquí) ———
from django.db import models
class MainAppModel(models.Model):
    # TODO: define your fields
    created = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"MainAppModel #{self.pk}"
