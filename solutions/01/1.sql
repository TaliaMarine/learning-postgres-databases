-- ordered
select datname,
       pg_encoding_to_char(encoding) as encoding,
       datallowconn as allows_connections
from pg_database
where datname in ('template0', 'template1')
order by datname;
