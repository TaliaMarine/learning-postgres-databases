create extension pg_trgm;

create index customers_full_name_trgm on shop.customers using gin (full_name gin_trgm_ops);

create function shop.find_customers(q text)
returns table (id integer, full_name text, sim real)
language sql stable
as $$
  select c.id, c.full_name, similarity(c.full_name, q)
  from shop.customers c
  where c.full_name % q
  order by 3 desc, 1
$$;
