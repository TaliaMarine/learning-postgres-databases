create table shop.orders_archive (like shop.orders including defaults);
create table shop.order_items_archive (like shop.order_items);

with moved_orders as (
  delete from shop.orders
  where status = 'cancelled' and id <= 2000
  returning *
), moved_items as (
  delete from shop.order_items oi
  using moved_orders m
  where oi.order_id = m.id
  returning oi.*
), archived_orders as (
  insert into shop.orders_archive
  select * from moved_orders
)
insert into shop.order_items_archive
select * from moved_items;
