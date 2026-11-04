begin;
update shop.products set stock = 100 where id = 4;
savepoint before_zero;
update shop.products set stock = 0 where id = 5;
rollback to savepoint before_zero;
update shop.products set stock = 200 where id = 6;
commit;
