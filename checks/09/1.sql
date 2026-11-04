select (select count(*) from shop.products) = 501 as ok, 'there are 501 products (one new, none duplicated)' as what
union all select price = 49.00, 'SKU-00001 now costs 49.00' from shop.products where sku = 'SKU-00001'
union all select name = 'Premium tent' and stock = 232 and category_id = 10, 'SKU-00001 kept its name, stock and category' from shop.products where sku = 'SKU-00001'
union all select name = 'Desk fan' and price = 39.00 and stock = 25 and category_id = 6, 'SKU-90001 was inserted with the given values' from shop.products where sku = 'SKU-90001'
union all select count(*) = 1, 'exactly one SKU-90001 row' from shop.products where sku = 'SKU-90001';
