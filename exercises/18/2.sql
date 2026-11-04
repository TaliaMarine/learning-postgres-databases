-- Write a function shop.customer_lifetime_value(p_customer_id integer)
-- returning numeric: the sum of orders.total for that customer, counting only
-- orders whose status is 'shipped' or 'delivered'. A customer with no such
-- orders must get 0, not NULL. It only reads data, so mark it STABLE.
-- Run ./pg check 18 2 when you are done.

