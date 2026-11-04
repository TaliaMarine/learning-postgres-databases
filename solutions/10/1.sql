-- ordered
select sku, attrs ->> 'color' as color
from shop.products
where attrs @> '{"warranty_months": 36}'
  and (attrs ->> 'weight_g')::int < 300
order by sku;
