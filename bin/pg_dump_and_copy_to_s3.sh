#!/bin/sh

export PGHOST="$POSTGRES_URL"
export PGPORT="$POSTGRES_PORT"
export PGUSER="$POSTGRES_ROOT_USER"
export PGPASSWORD="$POSTGRES_ROOT_PASSWORD"
export BACKUP_DIR="$BACKUP_DIR"

#----------------------------------------------------------------------------
# Gestion des paramètres
#----------------------------------------------------------------------------
BACKUP_NAME="test-ban-postgres-$(date +%Y%m%d).dump"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

#----------------------------------------------------------------------------
# Log début traitement
#----------------------------------------------------------------------------
TIME_START=$(date +%s)
echo "$(date -Iseconds) - pg_dump commencé ..."

#----------------------------------------------------------------------------
# Traitement
#----------------------------------------------------------------------------

pg_dump -h $PGHOST --username="$PGUSER" --dbname="ban" \
  --format=custom \
  --no-owner \
  --no-acl \
  --file="$BACKUP_PATH" \
  --verbose

echo "Téléversement du backup sur le S3"


if [ -z "$S3_CONFIG_ACCESS_KEY_ID" ] || [ -z "$S3_CONFIG_SECRET_ACCESS_KEY" ]; then
    echo "Erreur: S3_CONFIG_ACCESS_KEY_ID et S3_CONFIG_SECRET_ACCESS_KEY doivent être définis."
    exit 1
fi

export RCLONE_CONFIG_MYS3_PROVIDER=Other
export RCLONE_CONFIG_MYS3_TYPE=s3
export RCLONE_CONFIG_MYS3_ACCESS_KEY_ID="$S3_CONFIG_ACCESS_KEY_ID"
export RCLONE_CONFIG_MYS3_SECRET_ACCESS_KEY="$S3_CONFIG_SECRET_ACCESS_KEY"
export RCLONE_CONFIG_MYS3_ENDPOINT="$S3_ENDPOINT_URL"
export RCLONE_CONFIG_MYS3_REGION="$S3_REGION"
export RCLONE_CONFIG_MYS3_FORCE_PATH_STYLE=true
export RCLONE_CONFIG_MYS3_NO_CHECK_BUCKET=true

echo "Copie de $BACKUP_PATH vers mys3://$S3_BUCKET/backup-postgresIGN/$BACKUP_PATH"

rclone copyto "$BACKUP_PATH" "mys3:$S3_BUCKET/backup-postgresIGN/$BACKUP_NAME" -vv

echo "Transfert terminé"


#----------------------------------------------------------------------------
# Log fin traitement
#----------------------------------------------------------------------------
TIME_END=$(date +%s)
echo "$(date -Iseconds) - Dump et transfère vers S3 - completé en $(($TIME_END - $TIME_START)) secondes"
