update shop.orders set status = 'cancelled' where id in (select id from shop.orders where status = 'pending' order by id limit 3);
update shop.orders set status = status where id in (select id from shop.orders where status = 'paid' order by id limit 5);
update shop.orders set total = total + 1 where id in (select id from shop.orders where status = 'delivered' order by id limit 5);
update shop.orders set status = 'shipped' where id = (select min(id) from shop.orders where status = 'paid');

select to_regclass('shop.order_status_log') is not null as ok, 'table shop.order_status_log exists' as what
union all select (select count(*) = 4 from shop.order_status_log), 'exactly 4 status changes were logged (no-op updates add nothing)'
union all select (select count(*) = 3 from shop.order_status_log where old_status = 'pending' and new_status = 'cancelled'), 'pending to cancelled was recorded 3 times'
union all select (select count(*) = 1 from shop.order_status_log where old_status = 'paid' and new_status = 'shipped'), 'paid to shipped was recorded once'
union all select (select count(distinct order_id) = 4 from shop.order_status_log), 'each row names a different order';
