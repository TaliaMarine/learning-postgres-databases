with recursive tree as (
  select id, name as top_category from shop.categories where parent_id is null
  union all
  select c.id, t.top_category
  from shop.categories c
  join tree t on c.parent_id = t.id
)
select t.top_category as category, count(p.id) as products
from tree t
left join shop.products p on p.category_id = t.id
group by t.top_category
order by t.top_category;
