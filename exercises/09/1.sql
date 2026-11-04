-- With ONE INSERT statement, add two products to shop.products:
--   SKU-00001  (already exists)  price 49.00   -> its price must be updated, nothing else may change
--   SKU-90001  (new)  name 'Desk fan', description 'A quiet desk fan', category_id 6, price 39.00, stock 25, created_at '2025-01-01'
-- The old row must not be duplicated or replaced. Run ./pg check 09 1 when you are done.
-- For the SKU-00001 row, give any name, description, category_id, stock and created_at; they are ignored when the row already exists.

