-- Partition a copy of the orders by country.
-- Create shop.orders_by_country as a LIST-partitioned table on shipping_country
-- with the same columns as shop.orders (id, customer_id, status, ordered_at,
-- shipping_country, total; no foreign keys needed), and these partitions:
--   shop.orders_nl      holds 'NL'
--   shop.orders_de_be   holds 'DE' and 'BE'
--   shop.orders_other   the default partition (everything else)
-- Then copy every row of shop.orders into it. Run ./pg check 20 2 when done.

