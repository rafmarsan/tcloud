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

