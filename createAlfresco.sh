#!/bin/bash
set -e

PG_ALFRESCO_NAME=${PG_GERRIT_NAME:-pg-alfresco}
POSTGRES_IMAGE=${POSTGRES_IMAGE:-postgres}
ALF_HOSTNAME=${ALF_HOSTNAME:-$1}
CONTENT_STORE_PATH=${CONTENT_STORE_PATH:-/alf_content}
LDAP_HOST=${LDAP_HOST:-$2}
LDAP_SECURITY_CREDENTIALS=${LDAP_SECURITY_CREDENTIALS:-$3}

# Start PostgreSQL.
docker run \
--name ${PG_ALFRESCO_NAME} \
-P \
-e POSTGRES_USER=alfresco \
-e POSTGRES_PASSWORD=alfresco \
-e POSTGRES_DB=alfresco \
-d ${POSTGRES_IMAGE}

while [ -z "$(docker logs ${PG_ALFRESCO_NAME} 2>&1 | grep 'autovacuum launcher started')" ]; do
    echo "Waiting postgres ready."
    sleep 1
done

docker volume create --name alfresco-volume

docker run --name='alfresco' -p 445:445 -p 7070:7070 -p 8080:8080 \
--link ${PG_ALFRESCO_NAME}:pgdb \
-v alfresco-volume:${CONTENT_STORE_PATH} \
-e "CONTENT_STORE=${CONTENT_STORE_PATH}" \
-e "DB_KIND=postgresql" \
-e "DB_HOST=pgdb" \
-e "DB_USERNAME=alfresco" \
-e "DB_PASSWORD=alfresco" \
-e "DB_NAME=alfresco" \
-e "LDAP_ENABLED=true" \
-e "LDAP_URL=ldap://${LDAP_HOST}:389" \
-e "LDAP_AUTH_USERNAMEFORMAT=uid=%s,ou=people,o=ticc" \
-e "LDAP_USER_SEARCHBASE=ou=people,o=ticc" \
-e "LDAP_GROUP_SEARCHBASE=ou=alfresco,o=ticc" \
-e "LDAP_DEFAULT_ADMINS=admin" \
-e "LDAP_SECURITY_PRINCIPAL=uid=admin,o=ticc" \
-e "LDAP_SECURITY_CREDENTIALS=${LDAP_SECURITY_CREDENTIALS}" \
-e "ALFRESCO_HOSTNAME=${ALF_HOSTNAME}" \
-e "SHARE_HOSTNAME=${ALF_HOSTNAME}" \
-d gui81/alfresco
