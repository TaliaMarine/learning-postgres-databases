select coalesce((select n_tup_ins > 0 from pg_stat_user_tables where relid = to_regclass('shop.order_items')), false) as ok,
       'shop.order_items was dropped and loaded again' as what
union all
select (select count(*) from shop.order_items) = 599702, 'shop.order_items has all 599702 rows'
union all
select exists (select 1 from pg_constraint where conrelid = 'shop.order_items'::regclass and contype = 'p'),
       'shop.order_items has its primary key'
union all
select (select count(*) from pg_constraint where conrelid = 'shop.order_items'::regclass and contype = 'f') = 2,
       'shop.order_items has both foreign keys'
union all
select (select count(*) from shop.orders) = 200000 and (select count(*) from shop.products) = 500,
       'the other tables were left alone';
