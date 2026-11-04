create view shop.v_country_revenue as
select c.country, count(*) as orders, sum(o.total) as revenue
from shop.orders o
join shop.customers c on c.id = o.customer_id
where o.status in ('shipped', 'delivered')
group by c.country;
