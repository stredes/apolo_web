from rest_framework.decorators import api_view
from rest_framework.response import Response
from etiquetas.services.printer import ZebraPrinter

@api_view(['POST'])
def print_label(request):
    ip = request.data.get('ip')
    port = request.data.get('port', 9100)
    zpl = request.data.get('zpl', '')
    ZebraPrinter(ip, port).print_label(zpl)
    return Response({'status': 'OK'})
