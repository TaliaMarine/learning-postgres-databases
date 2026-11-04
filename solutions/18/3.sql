create procedure shop.set_price(p_sku text, p_price numeric)
language plpgsql
as $$
begin
  if p_price is null or p_price <= 0 then
    raise exception 'price must be greater than 0, got %', p_price;
  end if;
  update shop.products set price = p_price where sku = p_sku;
  if not found then
    raise exception 'no product with sku %', p_sku;
  end if;
end;
$$;

call shop.set_price('SKU-00001', 59.90);
