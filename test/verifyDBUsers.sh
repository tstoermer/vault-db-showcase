#!/bin/bash

set -e

export VAULT_ADDR=http://localhost:8200

info(){
  echo "[$(date +"%Y-%m-%d %T")] $1"
}

runPSQL(){
  echo "$4" | docker exec -i -e PGPASSWORD="$2" docker_postgres_1 psql -U"$1" -d "$3"
}

getUsername(){
  username=$(echo "$1" | jq -r '.data.username')
  echo "$username"
}

getPassword(){
  password=$(echo "$1" | jq -r '.data.password')
  echo "$password"
}

getUsernamePassword(){
  username=$(echo "$1" | jq -r '.data.username')
  password=$(echo "$1" | jq -r '.data.password')
  echo "$username" "$password"
}

ADMIN_USER_JSON=$(vault read -format=json db-utopia/creds/utopia_admin_role)
APP_USER_JSON=$(vault read -format=json db-utopia/creds/utopia_app_role)
READ_USER_JSON=$(vault read -format=json db-utopia/creds/utopia_read_role)

CREATE_INHABITANT_TABLE=$(cat <<EOF
SET ROLE 'utopia_admin';
CREATE TABLE utopia.inhabitant (id INTEGER CONSTRAINT inhabitant_pk PRIMARY KEY, first_name varchar(100), surename varchar(100));
EOF
)
DROP_INHABITANT_TABLE=$(cat <<EOF
DROP TABLE utopia.inhabitant;
EOF
)

CREATE_INVALID_TABLE=$(cat <<EOF
CREATE TABLE utopia.invalid (id INTEGER CONSTRAINT invalid_pk PRIMARY KEY, should varchar(100), never varchar(100), exist varchar(100));
EOF
)

SELECT_INHABITANT_TABLE=$(cat <<EOF
SELECT count(*) FROM utopia.inhabitant;
EOF
)

INSERT_INHABITANT=$(cat <<EOF
INSERT INTO utopia.inhabitant (id, first_name, surename) VALUES (1, 'Post', 'Gres');
EOF
)

info "[Admin User]"
info "+ can drop table"
runPSQL $(getUsernamePassword "$ADMIN_USER_JSON") utopia "$DROP_INHABITANT_TABLE"
info "+ can create table"
runPSQL $(getUsernamePassword "$ADMIN_USER_JSON") utopia "$CREATE_INHABITANT_TABLE"
info "+ can select table"
runPSQL $(getUsernamePassword "$ADMIN_USER_JSON") utopia "$SELECT_INHABITANT_TABLE"

info "[App User]"
info "+ can insert data"
runPSQL $(getUsernamePassword "$APP_USER_JSON") utopia "$INSERT_INHABITANT"
info "+ can select table"
runPSQL $(getUsernamePassword "$APP_USER_JSON") utopia "$SELECT_INHABITANT_TABLE"
info "- cannot create table"
runPSQL $(getUsernamePassword "$APP_USER_JSON") utopia "$CREATE_INVALID_TABLE"
info "- cannot drop table"
runPSQL $(getUsernamePassword "$APP_USER_JSON") utopia "$DROP_INHABITANT_TABLE"

info "[Read User]"
info "+ can select table"
runPSQL $(getUsernamePassword "$READ_USER_JSON") utopia "$SELECT_INHABITANT_TABLE"
info "- cannot create table"
runPSQL $(getUsernamePassword "$READ_USER_JSON") utopia "$CREATE_INVALID_TABLE"
info "- cannot drop table"
runPSQL $(getUsernamePassword "$READ_USER_JSON") utopia "$DROP_INHABITANT_TABLE"

