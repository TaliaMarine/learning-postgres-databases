insert into shop.products (sku, name, description, category_id, price, stock, created_at)
values ('  sku-77001 ', 'Trigger test', 'inserted by the check', 5, 9.99, 1, '2025-01-01');
update shop.products set sku = ' sku-77002' where sku = 'SKU-00001' or sku = 'sku-00001';

select exists (select 1 from pg_trigger where tgrelid = 'shop.products'::regclass and tgname = 'products_clean_sku' and not tgisinternal) as ok, 'trigger products_clean_sku exists on shop.products' as what
union all select exists (select 1 from shop.products where sku = 'SKU-77001'), 'an inserted sku is trimmed and upper-cased'
union all select not exists (select 1 from shop.products where sku <> upper(trim(sku))), 'no sku has stray spaces or lower-case letters'
union all select exists (select 1 from shop.products where sku = 'SKU-77002'), 'an updated sku is cleaned too';
