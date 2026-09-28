# podman build -t ssh-ubuntu:24 .
# podman rm -f ubuntu && podman run -d --privileged --name ubuntu -h ubuntu -p 2222:22 ssh-ubuntu:24 && scp userlist.txt script.sh ubuntu:/home/ansible/
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias y Fish
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        sudo \
        fish \
        vim \
        unzip \
        ncurses-bin \
        lsof \
        locales \
        procps \
        binutils \
        file \
        iproute2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /run/sshd && \
    ssh-keygen -A

# Crear usuario ansible
RUN groupadd -g 5000 ansible && \
    useradd -m -u 5000 -g ansible -s /bin/bash ansible && \
    usermod -aG sudo ansible && \
    echo "ansible ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible && \
    chmod 440 /etc/sudoers.d/ansible && \
    mkdir -p /home/ansible/.ssh && \
    chown -R ansible:ansible /home/ansible/.ssh && \
    chmod 700 /home/ansible/.ssh

# Configuración de Vim
COPY vimrc /home/ansible/.vimrc

RUN chown ansible:ansible /home/ansible/.vimrc && \
    chmod 644 /home/ansible/.vimrc

# Copiar clave pública
COPY id_ansible.pub /home/ansible/.ssh/authorized_keys

RUN chown ansible:ansible /home/ansible/.ssh/authorized_keys && \
    chmod 600 /home/ansible/.ssh/authorized_keys

# Configurar SSH
RUN sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    echo "AllowUsers ansible" >> /etc/ssh/sshd_config

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e"]
