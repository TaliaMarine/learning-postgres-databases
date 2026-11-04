\setenv PGDATABASE :DBNAME
\setenv PGUSER postgres

create role lab_23_owner nologin;
create database lab_23_restored owner lab_23_owner template template0;

\! pg_dump -Fc -n shop -f /tmp/lab_23_3.dump
-- --no-owner skips the ALTER ... OWNER TO commands in the archive;
-- --role makes pg_restore run as lab_23_owner, so lab_23_owner creates (and owns) everything.
\! pg_restore -d lab_23_restored --no-owner --role=lab_23_owner --exit-on-error /tmp/lab_23_3.dump
\! rm -f /tmp/lab_23_3.dump
