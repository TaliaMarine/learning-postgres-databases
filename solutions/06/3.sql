-- ordered
with promo (name, period) as (
  values ('spring',    daterange('2025-03-01', '2025-03-15')),
         ('mid_spring', daterange('2025-03-10', '2025-04-01')),
         ('april',     daterange('2025-04-01', '2025-05-01'))
)
select p.name as promo,
       count(o.id) as orders,
       coalesce(sum(o.total), 0) as revenue
from promo p
left join shop.orders o
  on p.period @> (o.ordered_at at time zone 'UTC')::date
group by p.name
order by p.name;
