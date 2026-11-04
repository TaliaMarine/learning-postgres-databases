create publication lab_orders_pub
  for table shop.orders, shop.order_items
  with (publish = 'insert, update');
