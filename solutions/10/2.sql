alter table shop.products
  add column weight_g integer generated always as ((attrs ->> 'weight_g')::int) stored;
create index products_weight_g_idx on shop.products (weight_g);
