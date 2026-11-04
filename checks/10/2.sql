select exists (select 1 from information_schema.columns
               where table_schema = 'shop' and table_name = 'products' and column_name = 'weight_g'
                 and data_type = 'integer' and is_generated = 'ALWAYS') as ok,
       'shop.products.weight_g is a generated integer column' as what
union all
select (select count(*) = 0 from shop.products where weight_g is distinct from (attrs ->> 'weight_g')::int),
       'weight_g equals attrs->>weight_g for every product'
union all
select exists (select 1 from pg_index i
               join pg_attribute a on a.attrelid = i.indrelid and a.attnum = i.indkey[0]
               where i.indrelid = 'shop.products'::regclass and a.attname = 'weight_g' and i.indnatts = 1),
       'an index starts on weight_g'
union all
select (select count(*) = 500 from shop.products), 'products were not deleted';
