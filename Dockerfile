FROM debian:bookworm-slim

ARG HTTP_PROXY
ARG HTTPS_PROXY
ENV HTTP_PROXY=$HTTP_PROXY
ENV HTTPS_PROXY=$HTTPS_PROXY


RUN CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")

# Installation des dépendances de base
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    gpg \
    gnupg \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Ajout des dépôts MongoDB
RUN curl -fsSL https://pgp.mongodb.com/server-6.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-6.0.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg] http://repo.mongodb.org/apt/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\")/mongodb-org/6.0 main" > /etc/apt/sources.list.d/mongodb-org-6.0.list

# Ajout des dépôts PostgreSQL avec la méthode sécurisée
RUN install -d /usr/share/postgresql-common/pgdg && \
    curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc && \
    echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(. /etc/os-release && echo \"$VERSION_CODENAME\")-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Installation des dépendances de base
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    mongodb-database-tools \
    postgresql-client-16 \
    rclone \
    && rm -rf /var/lib/apt/lists/*

# Création d'un utilisateur non-root
RUN useradd -u 1000 -ms /bin/bash dbuser

# Préparation des dossiers pour les volumes
RUN mkdir -p /tmp /var/tmp /home/dbuser/.cache /home/dbuser/.config && \
    chown -R dbuser:dbuser /home/dbuser /tmp /var/tmp

WORKDIR /home/dbuser

COPY --chmod=755 bin/ bin/

ENV BACKUP_DIR=/backups
RUN mkdir -p ${BACKUP_DIR} \
 && chown -R 1000:1000 ${BACKUP_DIR}
VOLUME ${BACKUP_DIR}

# Passage à l'utilisateur non-root
USER dbuser



