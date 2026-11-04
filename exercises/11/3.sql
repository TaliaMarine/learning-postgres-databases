-- Install pg_trgm, put a GIN trigram index called customers_full_name_trgm on
-- shop.customers (full_name), and create a function shop.find_customers(q text)
-- that returns (id integer, full_name text, sim real): the customers whose
-- full_name is similar to q (the % operator), best match first, then lowest id.
-- Run ./pg check 11 3 when you are done.

