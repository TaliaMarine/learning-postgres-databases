-- ordered
select id, name
from shop.products
where to_tsvector('english', description) @@ plainto_tsquery('english', 'quiet reliable')
order by id;
