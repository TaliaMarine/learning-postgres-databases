begin;
update shop.products set stock = stock - 10 where id = 1;
update shop.products set stock = stock + 10 where id = 2;
commit;

begin;
update shop.products set stock = 0 where id = 3;
rollback;
