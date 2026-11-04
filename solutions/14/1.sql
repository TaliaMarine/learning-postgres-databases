select count(*) from shop.customers where country = 'NL';
select count(*) from shop.customers where country = 'DE';
select count(*) from shop.customers where country = 'FR';

select s.calls, s.query
from pg_stat_statements s
where s.dbid = (select oid from pg_database where datname = current_database())
  and s.query = 'select count(*) from shop.customers where country = $1';
