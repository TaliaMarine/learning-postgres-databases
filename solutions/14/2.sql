-- ordered
select id, ordered_at, status
from shop.orders
where (ordered_at, id) < (timestamptz '2025-12-31 22:52:20.210931+00', 73472)
order by ordered_at desc, id desc
limit 5;
