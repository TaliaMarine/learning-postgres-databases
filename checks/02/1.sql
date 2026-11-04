select exists (select 1 from pg_namespace where nspname = 'archive') as ok,
       'schema archive exists' as what
union all
select to_regclass('archive.cancelled_orders') is not null,
       'table archive.cancelled_orders exists'
union all
select coalesce(case when to_regclass('archive.cancelled_orders') is null then false
       else (xpath('/row/c/text()', query_to_xml('select count(*) as c from archive.cancelled_orders', false, true, '')))[1]::text::bigint
            = (select count(*) from shop.orders where status = 'cancelled') end, false),
       'the copy has exactly the cancelled orders (same row count)'
union all
select coalesce(case when to_regclass('archive.cancelled_orders') is null then false
       else (xpath('/row/c/text()', query_to_xml($q$select count(*) as c from archive.cancelled_orders where status <> 'cancelled'$q$, false, true, '')))[1]::text::bigint = 0 end, false),
       'the copy holds no other statuses'
union all
select (select count(*) from shop.orders) = 200000, 'shop.orders is unchanged';
