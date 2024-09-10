# monitor.py
import time
import psutil
from prometheus_client import start_http_server, Gauge

# Crear métricas
cpu_usage = Gauge('cpu_usage_percent', 'CPU usage in percent')
memory_usage = Gauge('memory_usage_percent', 'Memory usage in percent')

def collect_metrics():
    while True:
        cpu_usage.set(psutil.cpu_percent())
        memory_usage.set(psutil.virtual_memory().percent)
        time.sleep(5)

if __name__ == '__main__':
    # Iniciar servidor HTTP en el puerto 8000
    start_http_server(8000)
    collect_metrics()