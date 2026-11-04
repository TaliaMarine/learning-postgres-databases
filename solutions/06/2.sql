create table shop.coupons (
  id            uuid primary key default gen_random_uuid(),
  code          text not null check (length(code) between 4 and 20),
  discount      numeric(5,2) not null check (discount > 0 and discount <= 100),
  valid_during  daterange not null
);
create unique index coupons_code_lower on shop.coupons (lower(code));
