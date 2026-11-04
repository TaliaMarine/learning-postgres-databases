\setenv PGDATABASE :DBNAME
\setenv PGUSER postgres
\! pg_dump -Fc -f /tmp/lab_23_2.dump

drop table shop.order_items;

-- pg_restore -t would bring back the table and its rows but not its constraints.
-- A list file selects every archive entry that belongs to the table.
\! pg_restore -l /tmp/lab_23_2.dump | grep ' shop order_items ' > /tmp/lab_23_2.list
\! pg_restore -L /tmp/lab_23_2.list --exit-on-error -d "$PGDATABASE" /tmp/lab_23_2.dump
\! rm -f /tmp/lab_23_2.dump /tmp/lab_23_2.list
