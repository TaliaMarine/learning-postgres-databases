create function pg_temp.fails(p_sql text) returns boolean language plpgsql as $$
begin
  execute p_sql;
  return false;
exception when others then
  return true;
end $$;

select exists (select 1 from pg_proc where oid = to_regprocedure('shop.set_price(text,numeric)') and prokind = 'p') as ok, 'shop.set_price(text, numeric) is a procedure' as what
union all select (select price = 59.90 from shop.products where sku = 'SKU-00001'), 'SKU-00001 now costs 59.90'
union all select pg_temp.fails($$call shop.set_price('SKU-00002', 0)$$), 'a price of 0 is rejected'
union all select pg_temp.fails($$call shop.set_price('SKU-00002', -5)$$), 'a negative price is rejected'
union all select pg_temp.fails($$call shop.set_price('NO-SUCH-SKU', 10)$$), 'an unknown sku is rejected'
union all select (select price <> 0 and price > 0 from shop.products where sku = 'SKU-00002'), 'a rejected call changes nothing';
