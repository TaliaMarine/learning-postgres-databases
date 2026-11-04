-- ordered
select c.relname as table_name,
       (select count(*) from pg_attribute a
         where a.attrelid = c.oid and a.attnum > 0 and not a.attisdropped) as columns,
       (select count(*) from pg_index i where i.indrelid = c.oid) as indexes
from pg_class c
where c.relnamespace = 'shop'::regnamespace and c.relkind = 'r'
order by c.relname;
