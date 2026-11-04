select coalesce((select array_agg(n) from public.lab_plan_nodes('select * from shop.orders where id = 5') n), '{}') = array['Index Scan'] as ok,
       'primary-key lookup gives exactly one node, Index Scan' as what
union all
select 'Seq Scan' = any (coalesce((select array_agg(n) from public.lab_plan_nodes('select * from analytics.events where kind = ''purchase''') n), '{}')),
       'a filter on kind scans the whole table (Seq Scan appears)'
union all
select coalesce((select array_agg(n) from public.lab_plan_nodes('select * from shop.orders o join shop.order_items i on i.order_id = o.id where o.id between 1 and 10') n), '{}') = array['Index Scan', 'Nested Loop'],
       'a join of ten orders gives Index Scan and Nested Loop, sorted'
union all
select pg_get_function_result('public.lab_plan_nodes(text)'::regprocedure) = 'SETOF text',
       'the function returns SETOF text';
