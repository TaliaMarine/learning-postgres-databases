create index events_user_feed_idx on analytics.events (customer_id, kind, occurred_at);
