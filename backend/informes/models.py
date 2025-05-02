from django.db import models

class Cliente(models.Model):
    nombre = models.CharField(max_length=200)
    direccion = models.CharField(max_length=300)
    ruc = models.CharField(max_length=20, unique=True)

    def __str__(self):
        return self.nombre
