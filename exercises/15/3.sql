-- Create a table public.tx_log (level text, row_is_mine boolean).
-- Then, in ONE transaction at the REPEATABLE READ isolation level:
--   1. lower the stock of product 8 by 1,
--   2. insert one row into tx_log: the current isolation level (read it
--      with current_setting) and whether the xmin of product 8's row now
--      equals the id of your own transaction,
--   3. commit.
-- Then run ./pg check 15 3.

