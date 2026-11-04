update shop.orders o
set status = 'cancelled'
from shop.customers c
where c.id = o.customer_id
  and c.status = 'closed'
  and o.status = 'pending';
