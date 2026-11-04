-- ordered
select t.tag,
       count(*) as products,
       count(*) filter (where (p.attrs ->> 'weight_g')::int > 1000) as heavy_products,
       round(avg(p.price), 2) as avg_price
from shop.products p
cross join lateral unnest(
  case when cardinality(p.tags) = 0 then array['(untagged)'] else p.tags end
) as t(tag)
group by t.tag
order by t.tag;
