-- Prepare logical replication of the order data. Create a publication named
-- lab_orders_pub that publishes the tables shop.orders and shop.order_items,
-- and only INSERT and UPDATE changes (not DELETE, not TRUNCATE).
-- PostgreSQL will warn that wal_level is too low for logical replication;
-- that warning is expected here. Then run ./pg check 24 2.

