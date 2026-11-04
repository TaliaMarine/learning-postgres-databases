create extension if not exists citext schema public;
alter table shop.customers alter column email type public.citext;
