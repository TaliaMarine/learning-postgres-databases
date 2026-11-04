select exists (select 1 from pg_proc where oid = to_regprocedure('shop.customer_lifetime_value(integer)') and prokind = 'f') as ok, 'shop.customer_lifetime_value(integer) is a function' as what
union all select (select provolatile = 's' from pg_proc where oid = to_regprocedure('shop.customer_lifetime_value(integer)')), 'it is marked STABLE'
union all select (select prorettype = 'numeric'::regtype from pg_proc where oid = to_regprocedure('shop.customer_lifetime_value(integer)')), 'it returns numeric'
union all select (select count(*) = 0 from (
          select c.id from shop.customers c
          where c.id in (1, 2, 3, 500, 7705)
            and shop.customer_lifetime_value(c.id) is distinct from
                (select coalesce(sum(o.total), 0) from shop.orders o where o.customer_id = c.id and o.status in ('shipped', 'delivered'))) bad),
          'the value is right for a sample of customers'
union all select (select shop.customer_lifetime_value(7705) = 0), 'a customer without shipped or delivered orders gets 0'
union all select (select shop.customer_lifetime_value(-1) = 0), 'an unknown customer id gets 0';
