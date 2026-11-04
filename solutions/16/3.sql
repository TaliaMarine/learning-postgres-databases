alter table analytics.events
  add constraint lab_events_customer_fk
  foreign key (customer_id) references shop.customers (id) not valid;
alter table analytics.events validate constraint lab_events_customer_fk;
create index concurrently events_customer_id_idx on analytics.events (customer_id);
