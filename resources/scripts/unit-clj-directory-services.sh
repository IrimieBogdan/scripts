#!/bin/sh
export PATH="$WORKSPACE/bin:$PATH"
mkdir -p "$WORKSPACE/bin"
cd "$WORKSPACE/bin"
wget --no-check-certificate -N https://raw.githubusercontent.com/technomancy/leiningen/2.5.0/bin/lein
chmod +x lein
cd "$WORKSPACE"

#Set DB and DS variables
DBUSER=rbac
DBHOST=vasu.delivery.puppetlabs.net
DBPORT=5432
DS_PORT=389
DS_CERT={ds_cert}
DS_USER={ds_user}
DS_HOST={ds_host}
DS_PASS={ds_pass}
DS_TYPE={ds_type}
DS_BASE_DN={ds_base_dn}
DS_USER_DN={ds_user_dn}
DS_GROUP_DN={ds_group_dn}

# Generate a temporary rbac database name
R_DBNAME=`echo "rbac_integration_$BUILD_ID" | tr - _`

# Generate a temporary activity database name
A_DBNAME=`echo "rbac_activity_integration_$BUILD_ID" | tr - _`

# Set up project specific database variables
export RBAC_DBNAME="//$DBHOST:$DBPORT/$R_DBNAME"
export RBAC_DBUSER="$DBUSER"
export PGPASSWORD="rbac851"
export RBAC_DBPASS="$PGPASSWORD"

export ACTIVITY_DBPASS="$PGPASSWORD"
export ACTIVITY_DBNAME="//$DBHOST:$DBPORT/$A_DBNAME"
export ACTIVITY_DBUSER="$DBUSER"

psql -h "$DBHOST" -U "$DBUSER" -d postgres -c "create database $A_DBNAME"
psql -h "$DBHOST" -U "$DBUSER" -d postgres -c "create database $R_DBNAME"
psql -h "$DBHOST" -U "$DBUSER" -d "$R_DBNAME" -c "create extension citext"


lein test :integration


# Clean up our database
psql -h "$DBHOST" -U "$DBUSER" -d postgres -c "drop database $A_DBNAME"
psql -h "$DBHOST" -U "$DBUSER" -d postgres -c "drop database $R_DBNAME"
