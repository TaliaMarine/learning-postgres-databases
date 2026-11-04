alter table shop.products set (
  fillfactor = 80,
  autovacuum_vacuum_scale_factor = 0.02,
  autovacuum_vacuum_threshold = 20
);
