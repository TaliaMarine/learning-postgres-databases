-- Products keep their weight inside the attrs jsonb column. Make it filterable
-- like a real column: add a stored generated integer column shop.products.weight_g
-- that always equals attrs ->> 'weight_g', and create a b-tree index on it
-- (any name). Run ./pg check 10 2 when you are done.

