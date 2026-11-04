\set ON_ERROR_STOP on
select setseed(0.42);

-- ---------------------------------------------------------------- categories
insert into shop.categories (name, parent_id) values
  ('Electronics', null), ('Home', null), ('Books', null), ('Outdoor', null);
insert into shop.categories (name, parent_id)
select v.name, p.id
from (values
  ('Audio','Electronics'), ('Computers','Electronics'), ('Phones','Electronics'),
  ('Kitchen','Home'), ('Furniture','Home'),
  ('Fiction','Books'), ('Science','Books'),
  ('Camping','Outdoor'), ('Cycling','Outdoor')
) as v(name, parent)
join shop.categories p on p.name = v.parent;

-- ----------------------------------------------------------------- customers
-- 20 000 customers over three years. Weighted countries, ~30% without phone.
insert into shop.customers
  (email, full_name, country, status, marketing_opt_in, phone, profile, created_at)
select
  lower(f.first || '.' || l.last || r.g) || '@' || d.domain,
  f.first || ' ' || l.last,
  c.code,
  case when r.s < 0.90 then 'active' when r.s < 0.97 then 'suspended' else 'closed' end,
  r.m < 0.35,
  case when r.p < 0.30 then null else '+' || (30 + (r.p * 20)::int) || (600000000 + (r.p * 399999999)::int) end,
  jsonb_build_object(
    'locale', case when c.code in ('NL','BE') then 'nl' when c.code = 'DE' then 'de'
                   when c.code = 'FR' then 'fr' else 'en' end,
    'newsletter', r.m < 0.35,
    'tier', case when r.t < 0.70 then 'basic' when r.t < 0.93 then 'plus' else 'pro' end
  ),
  timestamptz '2023-01-01 00:00:00+00' + (r.ts * interval '1095 days')
from (select g, random() s, random() m, random() p, random() t, random() ts,
             1 + floor(random() * 20)::int fi, 1 + floor(random() * 20)::int li,
             random() cw, 1 + floor(random() * 4)::int di
      from generate_series(1, 20000) g) r
cross join (select 1) _one
join (values (1,'Anna'),(2,'Ben'),(3,'Chloe'),(4,'Daan'),(5,'Eva'),(6,'Finn'),(7,'Gina'),(8,'Hugo'),
             (9,'Iris'),(10,'Jan'),(11,'Kim'),(12,'Liam'),(13,'Mila'),(14,'Noah'),(15,'Olga'),
             (16,'Pim'),(17,'Quinn'),(18,'Ruben'),(19,'Sara'),(20,'Tom')) f(i, first) on f.i = r.fi
join (values (1,'Jansen'),(2,'de Vries'),(3,'Bakker'),(4,'Visser'),(5,'Smit'),(6,'Meijer'),
             (7,'Mulder'),(8,'Bos'),(9,'Vos'),(10,'Peters'),(11,'Hendriks'),(12,'Dekker'),
             (13,'Brouwer'),(14,'Kok'),(15,'Jacobs'),(16,'Maas'),(17,'Verhoeven'),(18,'Koster'),
             (19,'Prins'),(20,'Huisman')) l(i, last) on l.i = r.li
join (values (1,'example.com'),(2,'example.org'),(3,'mail.test'),(4,'shop.test')) d(i, domain) on d.i = r.di
join (select code, sum(w) over (order by ord) - w as lo, sum(w) over (order by ord) as hi
      from (values (1,'NL',34),(2,'DE',20),(3,'BE',12),(4,'FR',10),(5,'GB',8),(6,'ES',6),(7,'IT',5),(8,'SE',3),(9,'US',2))
           t(ord, code, w)) c on r.cw * 100 >= c.lo and r.cw * 100 < c.hi
;

-- Friends referring friends: later customers sometimes name an earlier one.
update shop.customers c
set referred_by = 1 + floor(random() * (c.id - 1))::int
where c.id > 1 and random() < 0.12;

-- ------------------------------------------------------------------ products
insert into shop.products (sku, name, description, category_id, price, stock, tags, attrs, active, created_at)
select
  'SKU-' || lpad(g::text, 5, '0'),
  adj.word || ' ' || noun.word,
  'A ' || lower(adj.word) || ' ' || lower(noun.word) || ' for ' ||
    (array['everyday use','the office','travel','the kitchen','weekend trips','small spaces','long evenings'])[1 + (g % 7)] ||
    '. ' || (array['Quiet and reliable.','Built to last.','Easy to clean.','Lightweight and compact.','Great value.','Popular with our customers.'])[1 + (g % 6)],
  cat.id,
  round((5 + power(random(), 2.2) * 495)::numeric, 2),
  floor(random() * random() * 400)::int,
  case when g % 3 = 0 then array['sale','popular'] when g % 3 = 1 then array['new'] else array[]::text[] end,
  jsonb_build_object(
    'color', (array['black','white','red','blue','green','grey'])[1 + (g % 6)],
    'weight_g', 50 + (g * 37) % 5000,
    'warranty_months', (array[12,24,36])[1 + (g % 3)]
  ),
  random() < 0.95,
  timestamptz '2022-06-01 00:00:00+00' + (random() * interval '900 days')
from generate_series(1, 500) g
join (values (0,'Compact'),(1,'Premium'),(2,'Classic'),(3,'Smart'),(4,'Pocket'),(5,'Heavy-duty'),
             (6,'Portable'),(7,'Ergonomic'),(8,'Wireless'),(9,'Foldable')) adj(i, word) on adj.i = g % 10
join (values (0,'speaker'),(1,'laptop stand'),(2,'phone case'),(3,'kettle'),(4,'desk'),(5,'novel'),
             (6,'textbook'),(7,'tent'),(8,'bike light'),(9,'headphones'),(10,'blender'),(11,'chair'),
             (12,'lantern'),(13,'helmet'),(14,'keyboard'),(15,'charger'),(16,'backpack'),(17,'bottle'),
             (18,'toaster'),(19,'lamp')) noun(i, word) on noun.i = (g * 7) % 20
join lateral (select id from shop.categories where parent_id is not null order by id offset (g * 5) % 9 limit 1) cat on true;

-- ------------------------------------------------------------------- orders
-- 200 000 orders; heavy customers order far more often (skewed on purpose).
insert into shop.orders (customer_id, status, ordered_at, shipping_country)
select
  1 + floor(power(random(), 1.8) * 20000)::int,
  (case when r.s < 0.04 then 'pending' when r.s < 0.08 then 'paid' when r.s < 0.14 then 'shipped'
        when r.s < 0.88 then 'delivered' when r.s < 0.95 then 'cancelled' else 'refunded' end)::shop.order_status,
  timestamptz '2023-01-15 00:00:00+00' + (r.t * interval '1080 days'),
  'NL'
from generate_series(1, 200000) g
cross join lateral (select g as _g, random() s, random() t) r;

-- An order can only exist inside its customer's lifetime (signup .. end of 2025),
-- and ships to the customer's own country 90% of the time.
update shop.orders o
set ordered_at = c.created_at + interval '10 minutes'
                 + (extract(epoch from o.ordered_at - timestamptz '2023-01-15 00:00:00+00') / (1080 * 86400.0))
                   * (timestamptz '2025-12-31 23:00:00+00' - c.created_at - interval '10 minutes'),
    shipping_country = case when random() < 0.9 then c.country
                            else (array['NL','DE','BE','FR','GB'])[1 + floor(random() * 5)::int] end
from shop.customers c
where c.id = o.customer_id;

-- -------------------------------------------------------------- order items
insert into shop.order_items (order_id, line_no, product_id, quantity, unit_price)
select o.id, l.n, p.id, r.q, p.price
from shop.orders o
cross join lateral (select generate_series(1, 1 + floor(random() * 5)::int + (o.id * 0)) n) l
cross join lateral (select o.id as _o, l.n as _n,
                           1 + floor(power(random(), 1.4) * 500)::int pid,
                           1 + floor(power(random(), 3) * 4)::int q) r
join shop.products p on p.id = r.pid;

update shop.orders o set total = s.t
from (select order_id, sum(quantity * unit_price) t from shop.order_items group by order_id) s
where s.order_id = o.id;

-- ----------------------------------------------------------------- analytics
-- One million events. No indexes beyond the primary key.
insert into analytics.events (occurred_at, customer_id, kind, payload)
select
  timestamptz '2025-01-01 00:00:00+00' + (r.t * interval '364 days'),
  case when r.a < 0.35 then null else 1 + floor(power(r.c, 1.6) * 20000)::int end,
  case when r.k < 0.55 then 'page_view' when r.k < 0.80 then 'search' when r.k < 0.92 then 'add_to_cart'
       when r.k < 0.97 then 'checkout' else 'purchase' end,
  jsonb_build_object(
    'path', (array['/','/products','/cart','/checkout','/account','/search'])[1 + floor(r.p * 6)::int],
    'ms',   (20 + power(r.m, 3) * 2000)::int,
    'device', (array['desktop','mobile','tablet'])[1 + floor(r.d * 3)::int]
  )
from generate_series(1, 1000000) g
cross join lateral (select g as _g, random() t, random() a, random() c, random() k, random() p, random() m, random() d) r;

-- Statistics now, so plans in the lessons are stable from the first query.
analyze;
