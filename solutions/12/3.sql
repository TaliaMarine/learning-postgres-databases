create index events_purchase_customer_idx on analytics.events (customer_id)
  where kind = 'purchase';
