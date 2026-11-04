-- In ONE transaction, move 10 units of stock from product 1 to product 2
-- (shop.products.stock) and commit. Then, in a SECOND transaction, set the
-- stock of product 3 to 0 and roll that transaction back, so product 3 keeps
-- its old stock. Run ./pg check 15 1 when you are done.

