create table public.tx_log (level text, row_is_mine boolean);

begin isolation level repeatable read;
update shop.products set stock = stock - 1 where id = 8;
insert into public.tx_log
select current_setting('transaction_isolation'),
       (select xmin from shop.products where id = 8) = pg_current_xact_id()::xid;
commit;
