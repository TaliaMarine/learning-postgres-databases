-- Only 'purchase' events (3% of the table) are ever looked up by customer, with
--   select * from analytics.events where kind = 'purchase' and customer_id = 42
-- Create a PARTIAL index named events_purchase_customer_idx on
-- analytics.events that serves this query and stays under 1 MB.
-- Then run ./pg check 12 3.

