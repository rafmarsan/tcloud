## Primera parte:
El nodo réplica de la base de datos PostgreSQL no logra iniciarse correctamente

El contenedor que corresponde a la réplica de la base de datos PostgreSQL no logra iniciarse correctamente, se observa que el contenedor de la réplica  se encuentra en estado Exited o Restarting de forma continua.
Se espera que la réplica pueda conectarse correctamente al contenedor maestro y mantener la replicación física activa.
El comando docker ps debería mostrar una salida similar a:

```
CONTAINER ID   IMAGE                COMMAND                  STATUS          PORTS                     NAMES
xxxxxxx        postgres:15          "docker-entrypoint.s…"   Up 5 minutes    0.0.0.0:5432->5432/tcp    postgres-master
xxxxxxx        postgres:15          "docker-entrypoint.s…"   Up 5 minutes    0.0.0.0:5433->5432/tcp    postgres-replica
```

Y al revisar la conexión entre ambas bases de datos debería establecerse sin errores. 
En el HOME de tu usuario tienes un checks.sh que comprobará si la prueba es correcta, cuando se ejecute y se reciba un "OK" entonces estará correcta.

### Tareas
####  1.- Investiga y diagnostica la causa del problema que impide que la réplica de PostgreSQL se conecte al maestro.
- Ambos contenedores tienen conexion
- No estaba definida la conexion de la standby a nivel de `pg_hba`
- El usuario que de la replicacion no estaba creado o podriamos haber usado el propio `helsingor`, pero es buena practica usar el principio de minimos privilegios y crearemos `replicator` al cual agregaremos la contraseña ya definida en `PGPASSWORD`
- El fichero `postgres.conf` de la standby lo dejamos el por defecto, ya que al lanzar el comando `pg_basebackup` con la bandera `-R` ya nos configura el stream de replicacion con los datos de la copia

- Asegurar que el volumen que monta `/var/lib/postgres/data` tenga los permisos correctos
```
2026-09-25 19:33:30.094 UTC [1] FATAL: data directory "/var/lib/postgresql/data" has invalid permissions 2026-09-25 19:33:30.094 UTC [1] DETAIL: Permissions should be u=rwx (0700) or u=rwx,g=rx (0750).
```

#### 2.- Revisa la configuración del archivo docker-compose.yml y asegúrate de que las variables de entorno de conexión sean correctas.
- Montaremos el fichero `pg_hba.conf` en su ruta para dejarlo persistente en lugar de modificarlo dentro de contenedor y poder modificarlo con mayor facilidad
- Definamos el usuario `replicator` con la pass "r3pl1c4t0r" 
```
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'r3pl1c4t0r';
SELECT pg_reload_conf();
```

#### 3.- Verifica los archivos de configuración de PostgreSQL (`pg_hba.conf`, `postgresql.conf`) en el contenedor maestro para confirmar que permiten la conexión desde la réplica y `postgresql.conf` se encuentra fuera de la ruta estandar
- Habia que agregar la linea para permitir que la standby se conecte. Lo pusimos con `trust`, pero no es buena practica, asi que forzaremos `scram-sha-25`
```
host    replication     replicator      172.22.0.3/32           scram-sha-256
```

#### 4.- Confirma que el servicio de la réplica se inicie correctamente y que el estado de replicación sea activo en el contenedor maestro.
- Lanzar en la master `SELECT pg_reload_conf();`
- Verificar con: 
```
# En la primary -> state = streaming
SELECT pid, usename, client_addr, state, sync_state FROM pg_stat_replication;

---

helsingor=# SELECT pid, usename, client_addr, state, sync_state FROM pg_stat_replication;
 pid |  usename   | client_addr |   state   | sync_state
-----+------------+-------------+-----------+------------
 619 | replicator | 172.22.0.3  | streaming | async
(1 row)
```

```
# En la standby -> "t"
SELECT pg_is_in_recovery();

---

helsingor=# SELECT pg_is_in_recovery();
 pg_is_in_recovery
-------------------
 t
(1 row)
```

### Links:
- https://www.postgresql.org/docs/16/warm-standby.html#STREAMING-REPLICATION-AUTHENTICATION


## Segunda prueba:

Se quiere dar de alta a 30 usuarios con su correspondiente shell asociada y contraseña. Se ha conseguido un fichero con toda la información necesaria "userlist.txt". El nombre de usuario que se quiere para cada uno sigue el siguiente patrón: primera letra del nombre, seguido del primer apellido y el número 1. Si por alguna razón el nombre de usuario coincidiera se incrementaría el número.

Tareas
  1.- Dar de alta los 30 usuarios con su correspondiente password asociada.
  2.- Generar un archivo de log donde se mostratrá para cada usuario el nombre de usuario generado y ordenados todos de forma alfabética.
  3.- Todos los usuarios que tengan la shell fish pueden obtener privilegios de sudo.


Resolucion:
- bucle para recorrer fichero linea a linea
- funcion que encapsula la logica de generacion de nombre
```
set_name() {
  name=$(echo $1 | awk '{print tolower($0)}' | awk '{print $1}')
  surname=$(echo $1 | awk '{print tolower($0)}' | awk '{print $2}')
  echo "${name:0:1}$surname"
}
```
- saneamos el nombre de tildes y `ñ` -> usamos `sed` aunque lo ideal seria usar 
```
iconv -f UTF-8 -t ASCII//TRANSLI
```
usaremos el filtro custom `clean_text` -> ordenamos con `sort -f` asi podemos sacar el log ordenado alfabéticamente
```
clean_text() {
  sed 's/[Áá]/a/g' | sed 's/[Éé]/e/g' | sed 's/[Íí]/i/g' | sed 's/[Óó]/o/g' | sed 's/[Úú]/u/g' | sed 's/[ñÑ]/n/g'
}

cat ./userlist.txt | clean_text | sort -f | while read LINE; do
  ....
  ....
done
```
- para el numero autoincremental
```
 i=1
 if id "${_USERNAME}$i" &> /dev/null;then
   ((i++))
 fi
```

### Ansible
Esta tarea creo que tendria mas sentido en Ansible

- para la parte de saneamiento usaremos un filtro personalizado
https://docs.ansible.com/projects/ansible/latest/plugins/filter.html
  + tambien podemos usar el filtro de la comunidad `unicode_normalize` y eliminar los caracteres especiales
```
community.general.unicode_normalize('NFKD') | regex_replace('[\\u0300-\\u036f]', '')
```


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
