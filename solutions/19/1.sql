create function shop.products_clean_sku() returns trigger
language plpgsql
as $$
begin
  new.sku := upper(trim(new.sku));
  return new;
end;
$$;

create trigger products_clean_sku
before insert or update on shop.products
for each row execute function shop.products_clean_sku();
