# DB-Tool-Integration

## Statut

**travail en cours**

## Paramétrage

| Nom                  | Description                                                                  |
| -------------------- | ---------------------------------------------------------------------------- |
| BACKUP_DIR           | Répertoire de stockage local des sauvegardes                                 |
| PGHOST               | Nom d'hôte PostgreSQL                                                        |
| PGDATABASE           | Nom de la base de données PostgreSQL                                         |
| PGUSER               | Nom de l'utilisateur PostgreSQL                                              |
| PGPASSWORD           | Mot de passe PostgreSQL pour cet utilisateur (avnadmin)                      |
| S3_BUCKET            | Nom du bucket S3                                                             |
| S3_ACCESS_KEY_ID     | access_key_id dans le Secret s3-user-rw (backup) ou s3-user-ro (restore)     |
| S3_SECRET_ACCESS_KEY | secret_access_key dans le Secret s3-user-rw (backup) ou s3-user-ro (restore) |