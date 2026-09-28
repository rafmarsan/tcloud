## Tercera prueba:

Despliegue y Corrección de una Aplicación Web en Kubernetes ( herramienta de gestión: kubectl )

### Objetivo
Debes corregir el despliegue de una aplicación web configurada en kubernetes pero no funcional. Objetivo final es que la aplicación pueda ser accesible a través del puerto 8888 y devuelve el nombre de una ciudad. Para ello en el HOME de tu usuario tienes un checks.sh que comprobará si la prueba es correcta, cuando se ejecute y se reciba un "OK" entonces estará correcta.

Escenario:
- Deployment desplegado en Kubernetes que emplea imagen Docker llamada webapp.
- El pod se encuentra en estado `ImagePullBackOff`
- La aplicación escucha puerto 8888

* Cluster de kubernetes en kind sobre docker -> k3d?
* registry desplegado tambien en docker con una imagen de la `webapp` -> harbor?

Tareas
  1.- Asegurate de que la imagen webapp exista y sea accesible desde el clúster
  2.- Contenedor expuestos en el puerto 8888
  3.- Verifica estado correcto del pod.
  4.- Acceso aplicación a través de port-forward.


