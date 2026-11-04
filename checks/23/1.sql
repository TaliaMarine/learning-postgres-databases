\! pg_restore -l /tmp/lab_23_1.dump > /tmp/lab_23_1.list 2>/dev/null || true
select coalesce(pg_read_binary_file('/tmp/lab_23_1.dump', 0, 5, true) = 'PGDMP'::bytea, false) as ok,
       '/tmp/lab_23_1.dump exists and is a custom-format archive' as what
union all
select coalesce(position(convert_to(current_database(), 'UTF8') in pg_read_binary_file('/tmp/lab_23_1.dump', 0, 300, true)) > 0, false),
       'the dump was taken from this database'
union all
select coalesce(pg_read_file('/tmp/lab_23_1.list', true) like '%TABLE DATA shop orders %', false),
       'the dump contains the rows of shop.orders'
union all
select coalesce(pg_read_file('/tmp/lab_23_1.list', true) like '%TABLE DATA analytics events %', false),
       'the dump contains the rows of analytics.events';
\! rm -f /tmp/lab_23_1.dump /tmp/lab_23_1.list
