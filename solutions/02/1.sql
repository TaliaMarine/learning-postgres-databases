create schema archive;
create table archive.cancelled_orders as
  select * from shop.orders where status = 'cancelled';
