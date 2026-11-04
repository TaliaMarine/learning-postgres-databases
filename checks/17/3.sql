select coalesce((select 'fillfactor=80' = any (reloptions) from pg_class where oid = 'shop.products'::regclass), false) as ok, 'shop.products has fillfactor 80' as what
union all select coalesce((select 'autovacuum_vacuum_scale_factor=0.02' = any (reloptions) from pg_class where oid = 'shop.products'::regclass), false), 'autovacuum scale factor is 0.02'
union all select coalesce((select 'autovacuum_vacuum_threshold=20' = any (reloptions) from pg_class where oid = 'shop.products'::regclass), false), 'autovacuum threshold is 20'
union all select not exists (select 1 from pg_class where relnamespace = 'shop'::regnamespace and relkind = 'r' and relname <> 'products' and reloptions is not null), 'no other shop table was changed';
