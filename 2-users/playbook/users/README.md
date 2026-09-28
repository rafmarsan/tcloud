# Users
Creacion de usuarios sobre sistema operativos Linux


## Requirements
- El fichero de usuarios debe tener el patron: `<Nombre completo>,<Password>,<Shell>`
- Patrón: primera letra del nombre, seguido del primer apellido y el número 1. Si por alguna razón el nombre de usuario coincidiera se incrementaría el número
- Dar de alta usuarios con su correspondiente password asociada.
- Generar un archivo de log donde se mostratrá para cada usuario el nombre de usuario generado y ordenados todos de forma alfabética.
- Todos los usuarios que tengan la shell fish pueden obtener privilegios de sudo.

## Role Variables
| Variable      | Required | Default  | Choices / Type    | Comments                   |
|---------------|----------|----------|-------------------|----------------------------|
| userlist_file_path | yes |  | text | Path de OS donde se encuentra el fichero de usuarios |


## Dependencies
N/A

## Example Playbook
```yaml
---
- name: Manage Linux users
  hosts: "{{ server }}"
  gather_facts: false
  roles:
    - name: users

```
Lanzamiento:
```shell
ansible-playbook -i hosts playbook.yml -e userlist_file_path=/home/ansible/userlist.txt -e server=ubuntu
```

## License
BSD

## Author Information
Rafael Marin Sanchez

