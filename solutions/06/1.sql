-- ordered
select (ordered_at at time zone 'Europe/Amsterdam')::date as day,
       count(*) as orders
from shop.orders
where ordered_at >= timestamptz '2025-03-01 00:00 Europe/Amsterdam'
  and ordered_at <  timestamptz '2025-03-08 00:00 Europe/Amsterdam'
group by 1
order by 1;
