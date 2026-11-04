-- ordered
select n.nspname as schema_name, count(c.oid) as tables
from pg_namespace n
left join pg_class c on c.relnamespace = n.oid and c.relkind = 'r'
where n.nspname in ('analytics', 'public', 'shop')
group by n.nspname
order by n.nspname;
