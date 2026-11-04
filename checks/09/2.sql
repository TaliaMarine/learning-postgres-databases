select (select count(*) from shop.orders o join shop.customers c on c.id = o.customer_id
        where o.status = 'pending' and c.status = 'closed') = 0 as ok,
       'no pending order belongs to a closed customer' as what
union all select (select count(*) from shop.orders where status = 'pending') = 7699, 'the other 7699 pending orders are untouched'
union all select (select count(*) from shop.orders where status = 'cancelled') = 14440, 'cancelled went from 14197 to 14440 (243 more)'
union all select (select count(*) from shop.orders where status = 'paid') = 8111, 'paid orders are untouched'
union all select (select count(*) from shop.orders) = 200000, 'no order was added or removed';
