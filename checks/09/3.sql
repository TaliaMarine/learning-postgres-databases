select (select count(*) from shop.orders_archive) = 125 as ok, 'orders_archive holds the 125 cancelled orders' as what
union all select (select count(*) from shop.order_items_archive) = 339, 'order_items_archive holds their 339 lines'
union all select (select count(*) from shop.orders_archive where status <> 'cancelled' or id > 2000) = 0, 'only cancelled orders with id <= 2000 were archived'
union all select (select count(*) from shop.orders where status = 'cancelled' and id <= 2000) = 0, 'they are gone from shop.orders'
union all select (select count(*) from shop.orders) = 199875, 'shop.orders lost exactly 125 rows'
union all select (select count(*) from shop.order_items) = 599363, 'shop.order_items lost exactly 339 rows'
union all select (select count(*) from shop.order_items_archive a where not exists (select 1 from shop.orders_archive o where o.id = a.order_id)) = 0, 'every archived line belongs to an archived order';
