-- The query  select * from analytics.events where customer_id = 42
-- reads the whole 1 000 000-row table. Create an index named
-- events_customer_idx on analytics.events so that the planner can use it.
-- Then run ./pg check 12 1.

