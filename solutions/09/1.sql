insert into shop.products (sku, name, description, category_id, price, stock, created_at)
values
  ('SKU-00001', 'ignored', 'ignored', 1, 49.00, 0, '2025-01-01'),
  ('SKU-90001', 'Desk fan', 'A quiet desk fan', 6, 39.00, 25, '2025-01-01')
on conflict (sku) do update
  set price = excluded.price;
