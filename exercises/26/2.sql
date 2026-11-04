-- Customers' e-mail addresses should be unique regardless of case
-- ('Anna@Example.com' and 'anna@example.com' are the same address).
--   1. install the extension citext in the schema public;
--   2. change the type of shop.customers.email to citext;
--   3. show that it worked: no row may be added whose email differs from an
--      existing one only in case (the unique constraint already exists).
-- Then run ./pg check 26 2.

