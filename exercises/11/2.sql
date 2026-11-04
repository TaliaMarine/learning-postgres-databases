-- Add a column called search to shop.products: a tsvector that PostgreSQL keeps
-- up to date by itself, built from name and description with the english
-- configuration. Then create a GIN index on it called products_search_idx.
-- Run ./pg check 11 2 when you are done.

