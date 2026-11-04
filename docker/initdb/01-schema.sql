-- Course dataset: a small web shop plus an analytics event stream.
-- Runs once, on first start of an empty volume, inside the "shop" database.
-- Everything is deterministic (setseed) so lesson output matches your screen.

\set ON_ERROR_STOP on
select setseed(0.42);

create schema course;      -- bookkeeping for the course tooling itself
create schema shop;        -- transactional data
create schema analytics;   -- the big append-only table

create extension if not exists pg_stat_statements;

create type shop.order_status as enum
  ('pending', 'paid', 'shipped', 'delivered', 'cancelled', 'refunded');

create table shop.customers (
  id               integer generated always as identity primary key,
  email            text        not null unique,
  full_name        text        not null,
  country          char(2)     not null,
  status           text        not null default 'active'
                     check (status in ('active', 'suspended', 'closed')),
  marketing_opt_in boolean     not null default false,
  phone            text,
  referred_by      integer     references shop.customers (id),
  profile          jsonb       not null default '{}',
  created_at       timestamptz not null
);

create table shop.categories (
  id        integer generated always as identity primary key,
  name      text not null unique,
  parent_id integer references shop.categories (id)
);

create table shop.products (
  id          integer generated always as identity primary key,
  sku         text           not null unique,
  name        text           not null,
  description text           not null,
  category_id integer        not null references shop.categories (id),
  price       numeric(10, 2) not null check (price > 0),
  stock       integer        not null check (stock >= 0),
  tags        text[]         not null default '{}',
  attrs       jsonb          not null default '{}',
  active      boolean        not null default true,
  created_at  timestamptz    not null
);

create table shop.orders (
  id               integer generated always as identity primary key,
  customer_id      integer          not null references shop.customers (id),
  status           shop.order_status not null,
  ordered_at       timestamptz      not null,
  shipping_country char(2)          not null,
  total            numeric(12, 2)   not null default 0
);

create table shop.order_items (
  order_id   integer        not null references shop.orders (id),
  line_no    smallint       not null,
  product_id integer        not null references shop.products (id),
  quantity   smallint       not null check (quantity > 0),
  unit_price numeric(10, 2) not null,
  primary key (order_id, line_no)
);

-- The big one. Deliberately has NO secondary indexes: lessons add them.
create table analytics.events (
  id          bigint generated always as identity primary key,
  occurred_at timestamptz not null,
  customer_id integer,                 -- null = anonymous visitor
  kind        text        not null,
  payload     jsonb       not null default '{}'
);

