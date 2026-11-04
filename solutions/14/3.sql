create index events_customer_time_idx on analytics.events (customer_id, occurred_at);
analyze analytics.events;
