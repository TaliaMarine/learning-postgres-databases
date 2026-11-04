select stock = 100 as ok, 'product 4 stock is 100 (committed)' as what from shop.products where id = 4
union all select stock = 139, 'product 5 kept its stock (rolled back to the savepoint)' from shop.products where id = 5
union all select stock = 200, 'product 6 stock is 200 (updated after the savepoint rollback)' from shop.products where id = 6;
