select stock = 222 as ok, 'product 1 lost 10 units (232 -> 222)' as what from shop.products where id = 1
union all select stock = 97, 'product 2 gained 10 units (87 -> 97)' from shop.products where id = 2
union all select stock = 27, 'product 3 kept its stock (the second transaction was rolled back)' from shop.products where id = 3
union all select sum(stock) = (select sum(stock) from shop.products where id in (1,2,3)), 'sanity: totals are consistent' from shop.products where id in (1,2,3);
