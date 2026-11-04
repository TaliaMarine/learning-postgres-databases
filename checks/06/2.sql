create temp table r (ok boolean, what text);

insert into shop.coupons (code, discount, valid_during)
values ('SPRING25', 25.50, daterange('2025-03-01', '2025-04-01'));

do $$
begin
  begin
    insert into shop.coupons (code, discount, valid_during) values ('spring25', 10, daterange('2025-03-01', '2025-04-01'));
    insert into r values (false, 'code is unique regardless of case');
  exception when unique_violation then
    insert into r values (true, 'code is unique regardless of case');
  end;
  begin
    insert into shop.coupons (code, discount, valid_during) values ('BIGONE', 150, daterange('2025-03-01', '2025-04-01'));
    insert into r values (false, 'discount above 100 is rejected');
  exception when check_violation then
    insert into r values (true, 'discount above 100 is rejected');
  end;
  begin
    insert into shop.coupons (code, discount, valid_during) values ('AB', 5, daterange('2025-03-01', '2025-04-01'));
    insert into r values (false, 'codes shorter than 4 characters are rejected');
  exception when check_violation then
    insert into r values (true, 'codes shorter than 4 characters are rejected');
  end;
end $$;

select (select data_type from information_schema.columns where table_schema = 'shop' and table_name = 'coupons' and column_name = 'id') = 'uuid' as ok,
       'id is a uuid' as what
union all select column_default like '%gen_random_uuid%' or column_default like '%uuidv7%', 'id has a uuid default'
  from information_schema.columns where table_schema = 'shop' and table_name = 'coupons' and column_name = 'id'
union all select data_type = 'text', 'code is text (not varchar)'
  from information_schema.columns where table_schema = 'shop' and table_name = 'coupons' and column_name = 'code'
union all select numeric_precision = 5 and numeric_scale = 2, 'discount is numeric(5,2)'
  from information_schema.columns where table_schema = 'shop' and table_name = 'coupons' and column_name = 'discount'
union all select udt_name = 'daterange', 'valid_during is a daterange'
  from information_schema.columns where table_schema = 'shop' and table_name = 'coupons' and column_name = 'valid_during'
union all select (select count(*) from shop.coupons) = 1, 'only the first insert succeeded'
union all select valid_during @> date '2025-03-31' and not valid_during @> date '2025-04-01', 'range is half-open as inserted'
  from shop.coupons
union all select * from r;
