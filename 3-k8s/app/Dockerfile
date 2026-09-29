FROM python:3.11-alpine

WORKDIR /app

# Copiar e instalar dependencias primero para aprovechar la caché de Docker
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el código de la aplicación
COPY main.py .

# Exponer el puerto por defecto de FastAPI
EXPOSE 8000

# Comando para arrancar Uvicorn escuchando en todas las interfaces
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

