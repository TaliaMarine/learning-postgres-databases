select exists (select 1 from pg_views where schemaname = 'shop' and viewname = 'v_country_revenue') as ok, 'shop.v_country_revenue is a view' as what
union all select (select array_agg(attname::text order by attnum) = array['country', 'orders', 'revenue']
                  from pg_attribute where attrelid = to_regclass('shop.v_country_revenue') and attnum > 0 and not attisdropped),
                 'its columns are country, orders, revenue'
union all select (select count(*) = 9 from shop.v_country_revenue), 'one row per country (9 rows)'
union all select (select orders = 87824 and revenue = 68280660.31 from shop.v_country_revenue where country = 'NL'), 'NL has the right orders and revenue'
union all select (select sum(orders) = (select count(*) from shop.orders where status in ('shipped', 'delivered')) from shop.v_country_revenue), 'only shipped and delivered orders are counted';
