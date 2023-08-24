FROM rockylinux:8.8

ARG USERNAME="minio-user"

ARG PASS_MINIO_USER=root

ENV TIMEZONE Asia/Jakarta

ENV ROOT_PASSWORD $PASS_MINIO_USER

RUN dnf -y groupinstall 'Development Tools' && \
	dnf -y install ncurses-devel openssl-devel elfutils-libelf-devel python3.8 wget

## Define Minio Volumes
ARG MINIO_VOLUMES=/minio
ARG MINIO_ROOT_USER=tutorial_dvc
ARG MINIO_ROOT_PASS=pass123456789

## Install Minio server
RUN wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio-20230816201730.0.0.x86_64.rpm -O minio.rpm && \
    dnf install -y minio.rpm 

## Setup minio service
RUN { \
    echo '[Unit]'; \
    echo 'Description=MinIO'; \
    echo 'Documentation=https://min.io/docs/minio/linux/index.html'; \
    echo 'Wants=network-online.target'; \
    echo 'After=network-online.target'; \
    echo 'AssertFileIsExecutable=/usr/local/bin/minio'; \
    echo 'AssertFileNotEmpty=/etc/default/minio'; \
    echo ''; \
    echo '[Service]'; \
    echo 'WorkingDirectory=/usr/local'; \
    echo ''; \
    echo 'User=minio-user'; \
    echo 'Group=minio-user'; \
    echo 'ProtectProc=invisible'; \
    echo ''; \
    echo 'EnvironmentFile=-/etc/default/minio'; \
    echo 'ExecStartPre=/bin/bash -c "if [ -z \"${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\"; exit 1; fi"'; \
    echo 'ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES'; \
    echo ''; \
    echo 'Restart=always'; \
    echo ''; \
    echo 'LimitNOFILE=65536'; \
    echo ''; \
    echo 'TasksMax=infinity'; \
    echo ''; \
    echo 'TimeoutStopSec=infinity'; \
    echo 'SendSIGKILL=no'; \
    echo ''; \
    echo 'WantedBy=multi-user.target'; \
    } > /etc/systemd/system/minio.service;

## Setup Minio User
RUN groupadd -r ${USERNAME} && \
    useradd -m -r -g ${USERNAME} ${USERNAME}

RUN echo ${USERNAME}:${PASS_MINIO_USER} | chpasswd

RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME} && \
	usermod -a -G wheel ${USERNAME}

ENV MINIO_ROOT_USER $MINIO_ROOT_USER
ENV MINIO_ROOT_PASSWORD $MINIO_ROOT_PASS
ENV MINIO_VOLUMES $MINIO_VOLUMES

## Setup Default Minio Environment Variable
RUN { \
    echo 'MINIO_ROOT_USER=${MINIO_ROOT_USER}'; \
    echo 'MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASS}'; \
    echo 'MINIO_VOLUMES="${MINIO_VOLUMES}"'; \
    } > /etc/default/minio

## Create a path for minio 
RUN mkdir -p ${MINIO_VOLUMES}
RUN chown -R ${USERNAME} ${MINIO_VOLUMES} && \
    chmod 775 ${MINIO_VOLUMES}


## Enable Minio Service
RUN systemctl enable minio.service

## Change user and group user of minio server
RUN chown -R ${USERNAME} /usr/local/bin/minio

RUN echo '/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES --console-address ":9001"' >> start_server.sh && \
    chmod 755 start_server.sh

# RUN chown -R ${USERNAME} start_server.sh

# USER ${USERNAME}

VOLUME ${MINIO_VOLUMES}

EXPOSE 9000 9001

ENTRYPOINT ["bash", "start_server.sh"]