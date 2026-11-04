alter table shop.products
  add column search tsvector generated always as (
    setweight(to_tsvector('english', name), 'A') ||
    setweight(to_tsvector('english', description), 'B')
  ) stored;

create index products_search_idx on shop.products using gin (search);
