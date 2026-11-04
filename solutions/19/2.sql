create table shop.order_status_log (
  order_id   integer,
  old_status shop.order_status,
  new_status shop.order_status
);

create function shop.log_order_status() returns trigger
language plpgsql
as $$
begin
  insert into shop.order_status_log (order_id, old_status, new_status)
  values (new.id, old.status, new.status);
  return null;
end;
$$;

create trigger orders_status_log
after update on shop.orders
for each row
when (old.status is distinct from new.status)
execute function shop.log_order_status();
