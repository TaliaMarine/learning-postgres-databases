select count(*) = 1 as ok, 'tx_log has exactly one row' as what from public.tx_log
union all select coalesce(bool_and(level = 'repeatable read'), false), 'the row was written at repeatable read' from public.tx_log
union all select coalesce(bool_and(row_is_mine), false), 'the updated row carried your own transaction id in xmin' from public.tx_log
union all select stock = 8, 'product 8 stock went from 9 to 8' from shop.products where id = 8;
