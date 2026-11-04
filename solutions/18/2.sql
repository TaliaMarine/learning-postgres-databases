create function shop.customer_lifetime_value(p_customer_id integer)
returns numeric
language sql
stable
as $$
  select coalesce(sum(total), 0)
  from shop.orders
  where customer_id = p_customer_id
    and status in ('shipped', 'delivered')
$$;
