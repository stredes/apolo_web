from zebra import Zebra

class ZebraPrinter:
    def __init__(self, ip, port=9100):
        self.z = Zebra()
        self.z.setqueue(f"{ip}:{port}")

    def print_label(self, zpl_code: str):
        self.z.output(zpl_code)
