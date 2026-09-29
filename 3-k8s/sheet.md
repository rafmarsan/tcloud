## 1. Consultar el Catálogo (Ver qué hay)
```
# Listar todos los repositorios guardados en el registro
curl http://localhost:5000/v2/_catalog

# Listar las etiquetas (tags) de la imagen
curl http://localhost:5000/v2/IMAGEN/tags/list
```

## 2. Subir una Imagen (Push)
```
# 1. Añadir la etiqueta con la dirección del registro local
podman tag localhost/IMAGE:TAG localhost:5000/IMAGEN:TAG

# 2. Subir la imagen desactivando la verificación SSL
podman push localhost:5000/IMAGEN:TAG --tls-verify=false
```

## 3. Borrar una Imagen (Delete)
```
# 1. Obtener el 'Docker-Content-Digest' forzando el formato OCI actual
curl -v -H "Accept: application/vnd.oci.image.manifest.v1+json" \
       http://localhost:5000/v2/IMAGEN/manifests/TAG 2>&1 | grep -i docker-content-digest

# 2. Borrar la referencia en la API (Reemplaza con el sha256 obtenido arriba)
curl -X DELETE http://localhost:5000/v2/IMAGEN/manifests/sha256:HASH

# 3. Borrar la estructura de carpetas física del repositorio
podman exec -it registry rm -rf /var/lib/registry/docker/registry/v2/repositories/IMAGEN

# 4. Liberar el espacio físico en el disco (Garbage Collector)
podman exec -it registry registry garbage-collect /etc/distribution/config.yml
```

## 4. Configurar el nodo de K3d (Para el examen del alumno)
```
# 1. Crear de forma forzada la carpeta de configuraciones en el nodo Agent-1
docker exec k3d-k3s-default-agent-1 mkdir -p /etc/rancher/k3s

# 2. Copiar tu archivo registry.yaml local dentro del nodo
docker cp registry.yaml k3d-k3s-default-agent-1:/etc/rancher/k3s/registries.yaml

# 3. Reiniciar el contenedor para que K3s aplique el mirror HTTP sin romper producción
docker restart k3d-k3s-default-agent-1
```

---
## App FastApi
```
# 1. Construir la imagen local
podman build -t webapp:latest .

# 2. Probar el contenedor localmente en el puerto 8888 (como pide tu examen)
podman run -d -p 8888:8000 --name prueba-app webapp:latest

# 3. Validar que responde correctamente
curl http://localhost:8888
# Salida: {"mensaje":"Hola para TodoEnCloud. By Rafael Marin"}

# 4. Limpiar la prueba local
podman stop prueba-app && podman rm prueba-app

# 5. Etiquetar y subir a tu registro local para el laboratorio de Kubernetes
podman tag webapp:latest localhost:5000/webapp:latest
podman push localhost:5000/webapp:latest --tls-verify=false
```

