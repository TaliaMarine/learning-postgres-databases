-- ordered
select customer_id,
       id as order_id,
       ordered_at::date as order_date,
       sum(total) over (partition by customer_id order by ordered_at, id) as running_total
from shop.orders
where customer_id in (1, 2, 3)
order by customer_id, ordered_at, id;
