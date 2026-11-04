create table shop.orders_by_country (
  id               integer           not null,
  customer_id      integer           not null,
  status           shop.order_status not null,
  ordered_at       timestamptz       not null,
  shipping_country char(2)           not null,
  total            numeric(12, 2)    not null default 0,
  primary key (id, shipping_country)
) partition by list (shipping_country);

create table shop.orders_nl    partition of shop.orders_by_country for values in ('NL');
create table shop.orders_de_be partition of shop.orders_by_country for values in ('DE', 'BE');
create table shop.orders_other partition of shop.orders_by_country default;

insert into shop.orders_by_country
select id, customer_id, status, ordered_at, shipping_country, total from shop.orders;
