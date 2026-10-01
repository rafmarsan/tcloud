# Tercera prueba:

Despliegue y Corrección de una Aplicación Web en Kubernetes ( herramienta de gestión: kubectl )

## Objetivo
Debes corregir el despliegue de una aplicación web configurada en kubernetes pero no funcional. Objetivo final es que la aplicación pueda ser accesible a través del puerto 8888 y devuelve el nombre de una ciudad. Para ello en el HOME de tu usuario tienes un checks.sh que comprobará si la prueba es correcta, cuando se ejecute y se reciba un "OK" entonces estará correcta.

Escenario:
- Deployment desplegado en Kubernetes que emplea imagen Docker llamada webapp.
- El pod se encuentra en estado `ImagePullBackOff`
- La aplicación escucha puerto 8888

* Cluster de kubernetes en kind sobre docker -> k3d 
* registry desplegado tambien en docker con una imagen de la `webapp` -> harbor? CNCF Distribution

## Tareas

  1.- Asegurate de que la imagen webapp exista y sea accesible desde el clúster
  2.- Contenedor expuestos en el puerto 8888
  3.- Verifica estado correcto del pod.
  4.- Acceso aplicación a través de port-forward.


## Resolucion

### 1. Despliegue del registry

- Para la prueba se ha desplegado [CNCF Distribution](https://distribution.github.io/distribution/) en podman
- Para que el registry sea accesible desde los workers de k3d, se agregado el fichero [`registry.yaml`](./registry.yaml) en la ruta `/etc/rancher/k3s/registries.yaml` como aparece en la documentacion [Private Registry Configuration](https://docs.k3s.io/installation/private-registry)

### 2. Imagen webapp

- Se ha creado una api con FastApi para que responda en el puerto 8000 -> [main.py](./app/main.py)
- Se ha encapsulado en un Dockerfile y desplegada sobre uvicorn -> [Dockerfile](./app/Dockerfile)

### 3. Despliegue en k8s

- Se ha preparado un unico fichero [deployment](./deployment.yaml) con el `Deployment` y el `Service` asociado
- Para simiular el error `ImagePullBackOff` se ha puesto mal la url de la imagen y no se ha obligado a desplegar en el worker-1, el unico donde esta configurado el `registry.yaml`
```shell
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  16s               default-scheduler  Successfully assigned default/test-registry-deployment-75c946dc4d-bkgpj to k3d-k3s-default-agent-1
  Normal   BackOff    15s               kubelet            spec.containers{test-container}: Back-off pulling image "localhost:5000/webapp:latest"
  Warning  Failed     15s               kubelet            spec.containers{test-container}: Error: ImagePullBackOff
  Normal   Pulling    4s (x2 over 16s)  kubelet            spec.containers{test-container}: Pulling image "localhost:5000/webapp:latest"
  Warning  Failed     4s (x2 over 16s)  kubelet            spec.containers{test-container}: Failed to pull image "localhost:5000/webapp:latest": failed to pull and unpack image "localhost:5000/webapp:latest": failed to resolve reference "localhost:5000/webapp:latest": failed to do request: Head "https://localhost:5000/v2/webapp/manifests/latest": dial tcp [::1]:5000: connect: connection refused
  Warning  Failed     4s (x2 over 16s)  kubelet            spec.containers{test-container}: Error: ErrImagePull


➜ k get deployments.apps
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
test-registry-deployment   1/1     1            1           6m51s

➜ k get pods -o wide
NAME                                        READY   STATUS             RESTARTS   AGE   IP           NODE                      NOMINATED NODE   READINESS GATES
test-registry-deployment-75c946dc4d-bkgpj   0/1     ImagePullBackOff   0          47s   10.42.2.59   k3d-k3s-default-agent-1   <none>           <none>

➜ k get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
kubernetes   ClusterIP   10.43.0.1       <none>        443/TCP    352d
my-service   ClusterIP   10.43.125.175   <none>        8888/TCP   6m31s
```

- Para solventar el problema aseguramos el despliegue en el `worker-1` y corregimos la url
```shell
➜ k get pods
NAME                                       READY   STATUS    RESTARTS   AGE
test-registry-deployment-75d44d95f-rc4wr   1/1     Running   0          2s
```

### 4. Realizar `port-forward`
```shell
➜ k port-forward services/my-service 12345:8888
Forwarding from 127.0.0.1:12345 -> 8000
Forwarding from [::1]:12345 -> 8000
```
```shell
➜ curl localhost:12345
{"mensaje":"Hola para TodoEnCloud. By Rafael Marin"}
```



