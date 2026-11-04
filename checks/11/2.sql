select exists (select 1 from pg_attribute a
               where a.attrelid = 'shop.products'::regclass and a.attname = 'search'
                 and a.atttypid = 'tsvector'::regtype and a.attgenerated = 's') as ok,
       'products.search is a stored generated tsvector column' as what
union all select exists (select 1 from pg_indexes
                         where schemaname = 'shop' and indexname = 'products_search_idx'
                           and indexdef ilike '% using gin (search)%'),
       'products_search_idx is a GIN index on search'
union all select (select count(*) from shop.products where search @@ plainto_tsquery('english', 'kettle')) = 25,
       'search finds the 25 kettle products (name or description)'
union all select (select count(*) from shop.products where search @@ plainto_tsquery('english', 'kitchen lightweight')) = 12,
       'search finds 12 products for kitchen + lightweight';
