select count(*) from shop.products where stock < 10;
select count(*) from shop.products where price > 100;
select email from shop.customers where id = 7;
select email from shop.customers where id = 8;
select email from shop.customers where id = 9;
select pg_stat_force_next_flush();

select relname as table_name, seq_scan, idx_scan
from pg_stat_user_tables
where relid in ('shop.products'::regclass, 'shop.customers'::regclass);
