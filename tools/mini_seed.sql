-- Mini shop for the in-browser playground. Same table names and column names as
-- the Docker dataset, far fewer rows, fully deterministic (no random()).
create schema shop;
create schema analytics;
create schema course;

create type shop.order_status as enum ('pending','paid','shipped','delivered','cancelled','refunded');

create table shop.categories (
  id integer generated always as identity primary key,
  name text not null unique,
  parent_id integer references shop.categories (id)
);

create table shop.customers (
  id integer generated always as identity primary key,
  email text not null unique,
  full_name text not null,
  country char(2) not null,
  status text not null default 'active' check (status in ('active','suspended','closed')),
  marketing_opt_in boolean not null default false,
  phone text,
  referred_by integer references shop.customers (id),
  profile jsonb not null default '{}',
  created_at timestamptz not null
);

create table shop.products (
  id integer generated always as identity primary key,
  sku text not null unique,
  name text not null,
  description text not null,
  category_id integer not null references shop.categories (id),
  price numeric(10,2) not null check (price > 0),
  stock integer not null check (stock >= 0),
  tags text[] not null default '{}',
  attrs jsonb not null default '{}',
  active boolean not null default true,
  created_at timestamptz not null
);

create table shop.orders (
  id integer generated always as identity primary key,
  customer_id integer not null references shop.customers (id),
  status shop.order_status not null,
  ordered_at timestamptz not null,
  shipping_country char(2) not null,
  total numeric(12,2) not null default 0
);

create table shop.order_items (
  order_id integer not null references shop.orders (id),
  line_no smallint not null,
  product_id integer not null references shop.products (id),
  quantity smallint not null check (quantity > 0),
  unit_price numeric(10,2) not null,
  primary key (order_id, line_no)
);

create table analytics.events (
  id bigint generated always as identity primary key,
  occurred_at timestamptz not null,
  customer_id integer,
  kind text not null,
  payload jsonb not null default '{}'
);

insert into shop.categories (name, parent_id) values
  ('Electronics', null), ('Home', null), ('Books', null), ('Outdoor', null);
insert into shop.categories (name, parent_id) values
  ('Audio', 1), ('Computers', 1), ('Kitchen', 2), ('Fiction', 3), ('Camping', 4);

insert into shop.customers (email, full_name, country, status, marketing_opt_in, phone, profile, created_at) values
 ('anna.jansen@example.com',   'Anna Jansen',   'NL', 'active',    true,  '+31611111111', '{"tier":"plus","locale":"nl"}',  '2023-02-01 09:00+00'),
 ('ben.de.vries@example.org',  'Ben de Vries',  'NL', 'active',    false, null,           '{"tier":"basic","locale":"nl"}', '2023-03-14 10:30+00'),
 ('chloe.martin@mail.test',    'Chloe Martin',  'FR', 'active',    true,  '+33622222222', '{"tier":"pro","locale":"fr"}',   '2023-05-02 12:00+00'),
 ('daan.bakker@example.com',   'Daan Bakker',   'BE', 'suspended', false, null,           '{"tier":"basic","locale":"nl"}', '2023-07-19 08:15+00'),
 ('eva.muller@shop.test',      'Eva Müller',    'DE', 'active',    true,  '+49301234567', '{"tier":"plus","locale":"de"}',  '2024-01-10 17:45+00'),
 ('finn.smit@example.com',     'Finn Smit',     'NL', 'closed',    false, null,           '{"tier":"basic","locale":"nl"}', '2024-04-03 07:20+00'),
 ('gina.bos@mail.test',        'Gina Bos',      'GB', 'active',    false, '+447700900123','{"tier":"pro","locale":"en"}',   '2024-06-22 14:10+00'),
 ('hugo.visser@example.org',   'Hugo Visser',   'NL', 'active',    true,  null,           '{"tier":"plus","locale":"nl"}',  '2024-09-30 11:00+00');

update shop.customers set referred_by = 1 where email in ('ben.de.vries@example.org','chloe.martin@mail.test');
update shop.customers set referred_by = 3 where email = 'gina.bos@mail.test';

insert into shop.products (sku, name, description, category_id, price, stock, tags, attrs, active, created_at) values
 ('SKU-00001','Compact speaker',   'A compact speaker for everyday use.', 5, 49.99,  120, '{popular}', '{"color":"black","weight_g":640}',  true, '2024-01-05'),
 ('SKU-00002','Premium headphones','Quiet and reliable over-ear headphones.', 5, 189.00, 40,  '{sale}',   '{"color":"white","weight_g":260}',  true, '2024-02-11'),
 ('SKU-00003','Smart kettle',      'A kettle with a temperature setting.', 6, 79.50, 0,   '{}',         '{"color":"grey","weight_g":1100}', true, '2024-03-20'),
 ('SKU-00004','Laptop stand',      'Lightweight aluminium laptop stand.', 6, 24.95, 210, '{new}',      '{"color":"black","weight_g":420}',  true, '2024-05-02'),
 ('SKU-00005','Field novel',       'A novel about a long walk home.', 7, 14.90, 75, '{popular}', '{"color":"blue"}', true, '2024-06-15'),
 ('SKU-00006','Two-person tent',   'Built to last on wet weekends.', 8, 219.00, 12, '{}', '{"color":"green","weight_g":2100}', true, '2024-07-01'),
 ('SKU-00007','Bike light',        'Easy to clean, rechargeable.', 8, 16.50, 300, '{new}', '{"color":"red","weight_g":90}', true, '2024-08-09'),
 ('SKU-00008','Retro kettle',      'Great value for small spaces.', 6, 34.00, 58, '{sale}', '{"color":"red","weight_g":980}', false, '2024-08-30');

insert into shop.orders (customer_id, status, ordered_at, shipping_country, total) values
 (1,'delivered','2024-02-14 10:00+00','NL',0), (1,'shipped','2024-11-02 09:30+00','NL',0),
 (2,'delivered','2024-03-01 18:20+00','NL',0), (3,'cancelled','2024-05-18 13:00+00','FR',0),
 (3,'delivered','2024-06-05 08:45+00','FR',0), (5,'paid','2025-01-09 16:10+00','DE',0),
 (5,'delivered','2025-02-20 12:00+00','DE',0), (7,'refunded','2025-03-03 19:30+00','GB',0),
 (8,'pending','2025-04-01 07:00+00','NL',0), (1,'delivered','2025-05-22 11:11+00','NL',0),
 (4,'delivered','2025-06-30 15:00+00','BE',0), (8,'delivered','2025-07-14 09:00+00','NL',0);

insert into shop.order_items (order_id, line_no, product_id, quantity, unit_price) values
 (1,1,1,1,49.99), (1,2,4,2,24.95), (2,1,2,1,189.00),
 (3,1,5,3,14.90), (4,1,3,1,79.50), (5,1,6,1,219.00), (5,2,7,2,16.50),
 (6,1,4,1,24.95), (7,1,1,2,49.99), (8,1,7,1,16.50),
 (9,1,2,1,189.00), (10,1,3,1,79.50), (10,2,4,1,24.95),
 (11,1,5,1,14.90), (12,1,1,1,49.99);

update shop.orders o set total = s.t from (
  select order_id, sum(quantity * unit_price) t from shop.order_items group by order_id) s
where s.order_id = o.id;

insert into analytics.events (occurred_at, customer_id, kind, payload)
select timestamptz '2025-01-01 00:00+00' + (g * interval '53 minutes'),
       case when g % 3 = 0 then null else 1 + (g % 8) end,
       (array['page_view','page_view','search','add_to_cart','checkout','purchase'])[1 + g % 6],
       jsonb_build_object('path', (array['/','/products','/cart','/checkout','/search'])[1 + g % 5],
                          'ms', 20 + (g * 37) % 900)
from generate_series(1, 240) g;

analyze;
