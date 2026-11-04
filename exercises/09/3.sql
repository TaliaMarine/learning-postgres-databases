-- Move the cancelled orders with id <= 2000, together with their order_items,
-- out of shop.orders and shop.order_items into two new archive tables:
--   shop.orders_archive       (same columns as shop.orders)
--   shop.order_items_archive  (same columns as shop.order_items)
-- Create the two tables first. Then do the move in ONE statement, so no row is
-- ever lost or copied twice. Run ./pg check 09 3 when you are done.

