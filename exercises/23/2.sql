-- An accident to practise on. In this file:
--   1. take a custom-format dump of this database to /tmp/lab_23_2.dump
--      (use \setenv PGDATABASE :DBNAME, \setenv PGUSER postgres and \! as in exercise 1);
--   2. drop table shop.order_items;
--   3. restore ONLY shop.order_items from the dump: its rows, its primary key
--      and both of its foreign keys. Leave every other table alone.
-- Remove the dump file at the end. Then run ./pg check 23 2.

