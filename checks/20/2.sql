select (select relkind = 'p' from pg_class where oid = to_regclass('shop.orders_by_country')) as ok, 'shop.orders_by_country is a partitioned table' as what
union all select (select partstrat = 'l' from pg_partitioned_table where partrelid = to_regclass('shop.orders_by_country')), 'it is list-partitioned'
union all select (select count(*) = 200000 from shop.orders_by_country), 'all 200000 orders were copied'
union all select (select count(*) = (select count(*) from shop.orders where shipping_country = 'NL') from shop.orders_nl), 'orders_nl holds exactly the NL orders'
union all select (select count(*) = (select count(*) from shop.orders where shipping_country in ('DE', 'BE')) from shop.orders_de_be), 'orders_de_be holds exactly the DE and BE orders'
union all select (select count(*) = (select count(*) from shop.orders where shipping_country not in ('NL', 'DE', 'BE')) from shop.orders_other), 'orders_other holds the rest'
union all select (select count(*) = 1 from pg_class c join pg_partitioned_table p on p.partrelid = c.oid where c.oid = to_regclass('shop.orders_by_country') and p.partdefid = to_regclass('shop.orders_other')), 'orders_other is the default partition';
