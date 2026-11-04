-- Write a PL/pgSQL procedure shop.set_price(p_sku text, p_price numeric) that
-- sets the price of the product with that sku. It must raise an error when
-- p_price is not greater than 0, and also when no product has that sku.
-- Then use it (with CALL) to set the price of SKU-00001 to 59.90.
-- Run ./pg check 18 3 when you are done.

