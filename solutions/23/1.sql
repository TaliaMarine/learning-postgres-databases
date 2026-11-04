\setenv PGDATABASE :DBNAME
\setenv PGUSER postgres
\! pg_dump -Fc -f /tmp/lab_23_1.dump
