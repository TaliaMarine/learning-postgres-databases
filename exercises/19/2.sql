-- Keep a history of order status changes.
-- 1. Create the table shop.order_status_log with columns order_id integer,
--    old_status shop.order_status, new_status shop.order_status.
-- 2. Create an AFTER UPDATE trigger on shop.orders that adds one row to that
--    table whenever an order's status actually changes. Updates that leave the
--    status as it was (or change only other columns) must add nothing.
-- Run ./pg check 19 2 when you are done.

