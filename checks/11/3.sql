select exists (select 1 from pg_extension where extname = 'pg_trgm') as ok, 'pg_trgm is installed' as what
union all select exists (select 1 from pg_indexes
                         where schemaname = 'shop' and tablename = 'customers'
                           and indexname = 'customers_full_name_trgm'
                           and indexdef ilike '% using gin (full_name gin_trgm_ops)%'),
       'customers_full_name_trgm is a GIN trigram index on full_name'
union all select (select full_name from shop.find_customers('Anna Jansn') limit 1) = 'Anna Jansen',
       'the best match for "Anna Jansn" is Anna Jansen'
union all select (select count(*) from shop.find_customers('Anna Jansn')) = (select count(*) from shop.customers where full_name % 'Anna Jansn'),
       'find_customers returns every customer above the similarity threshold (284)'
union all select (select count(*) from shop.find_customers('zzzzzz')) = 0,
       'a nonsense query returns no rows'
union all select (select bool_and(sim >= 0.3) from shop.find_customers('Anna Jansn')),
       'every row is at least 0.3 similar'
union all select (select array_agg(id) from (select id from shop.find_customers('Anna Jansn') limit 3) s) = (select array_agg(id) from (select id from shop.customers where full_name = 'Anna Jansen' order by id limit 3) t),
       'ties are broken by lowest id';
