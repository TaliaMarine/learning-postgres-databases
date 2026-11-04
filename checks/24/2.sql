select exists (select 1 from pg_publication where pubname = 'lab_orders_pub') as ok, 'publication lab_orders_pub exists' as what
union all
select coalesce((select array_agg(schemaname || '.' || tablename order by tablename)
                 from pg_publication_tables where pubname = 'lab_orders_pub')
                = array['shop.order_items', 'shop.orders'], false),
       'it publishes exactly shop.orders and shop.order_items'
union all
select coalesce((select pubinsert and pubupdate from pg_publication where pubname = 'lab_orders_pub'), false),
       'it publishes inserts and updates'
union all
select coalesce((select not pubdelete and not pubtruncate from pg_publication where pubname = 'lab_orders_pub'), false),
       'it does not publish deletes or truncates';
