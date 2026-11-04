select format('%I.%I', n.nspname, c.relname) as table_name,
       round(current_setting('autovacuum_vacuum_threshold')::numeric
           + current_setting('autovacuum_vacuum_scale_factor')::numeric * c.reltuples)::bigint as vacuum_trigger
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname in ('shop', 'analytics') and c.relkind = 'r'
order by 1;
