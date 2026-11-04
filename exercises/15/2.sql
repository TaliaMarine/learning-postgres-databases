-- In ONE transaction, using a savepoint:
--   1. set the stock of product 4 to 100,
--   2. open a savepoint, then set the stock of product 5 to 0,
--   3. roll back to the savepoint (product 5 must keep its old stock),
--   4. set the stock of product 6 to 200,
--   5. commit.
-- Then run ./pg check 15 2.

