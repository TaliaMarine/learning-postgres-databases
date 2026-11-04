create publication lab_eu_orders
  for table shop.orders (id, customer_id, status, total, shipping_country)
  where (shipping_country in ('NL', 'BE', 'DE'))
  with (publish = 'insert, update');

-- The row filter uses shipping_country, so the replica identity (the columns
-- that identify an updated row) must include it. REPLICA IDENTITY FULL would
-- not work either: the column list must cover the whole replica identity.
create unique index orders_id_country_key on shop.orders (id, shipping_country);
alter table shop.orders replica identity using index orders_id_country_key;

update shop.orders set total = total where id = 1;
