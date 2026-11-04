-- For every ordinary table in the schemas shop and analytics, show how many
-- dead rows it needs before autovacuum visits it, using the settings in force
-- in your session: threshold + scale_factor * reltuples (the planner's row
-- estimate from pg_class), rounded to a whole number.
-- Return two columns: table_name (schema-qualified, e.g. shop.orders) and
-- vacuum_trigger (bigint). Run ./pg check 17 1 when you are done.

