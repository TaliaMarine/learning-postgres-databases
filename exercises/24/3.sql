-- A European warehouse should receive only part of shop.orders. Create a
-- publication lab_eu_orders that publishes INSERT and UPDATE changes of
-- shop.orders, only for rows whose shipping_country is 'NL', 'BE' or 'DE',
-- and only the columns id, customer_id, status, total, shipping_country.
-- After that, an ordinary UPDATE of shop.orders must still work, for example:
--   update shop.orders set total = total where id = 1;
-- (try it: at first it fails). Fix that without dropping the primary key and
-- without changing the publication. Then run ./pg check 24 3.

