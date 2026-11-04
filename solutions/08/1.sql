select shipping_country as country,
       count(*) as orders,
       count(*) filter (where status = 'delivered') as delivered,
       count(*) filter (where status in ('cancelled', 'refunded')) as lost
from shop.orders
group by shipping_country
order by shipping_country;
