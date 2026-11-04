create function pg_temp.update_works() returns boolean language plpgsql as $$
begin
  update shop.orders set total = total where id = 1;
  return true;
exception when others then
  return false;
end $$;

select exists (select 1 from pg_publication where pubname = 'lab_eu_orders') as ok, 'publication lab_eu_orders exists' as what
union all
select coalesce((select pubinsert and pubupdate and not pubdelete and not pubtruncate
                 from pg_publication where pubname = 'lab_eu_orders'), false),
       'it publishes inserts and updates only'
union all
select coalesce((select attnames::text[] = array['id', 'customer_id', 'status', 'shipping_country', 'total']
                 from pg_publication_tables where pubname = 'lab_eu_orders' and tablename = 'orders'), false),
       'it publishes the five required columns of shop.orders'
union all
select coalesce((select rowfilter like '%shipping_country%' and rowfilter like '%NL%' and rowfilter like '%BE%' and rowfilter like '%DE%'
                 from pg_publication_tables where pubname = 'lab_eu_orders' and tablename = 'orders'), false),
       'it has a row filter on shipping_country for NL, BE and DE'
union all
select exists (select 1 from pg_constraint where conrelid = 'shop.orders'::regclass and contype = 'p'),
       'shop.orders still has its primary key'
union all
select pg_temp.update_works(), 'an UPDATE of shop.orders works';
