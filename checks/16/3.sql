select c.convalidated as ok, 'lab_events_customer_fk exists and is validated' as what
from pg_constraint c where c.conname = 'lab_events_customer_fk' and c.conrelid = 'analytics.events'::regclass and c.contype = 'f'
union all select c.confrelid = 'shop.customers'::regclass, 'it references shop.customers'
from pg_constraint c where c.conname = 'lab_events_customer_fk'
union all select i.indisvalid and i.indisready, 'events_customer_id_idx exists and is valid'
from pg_index i where i.indexrelid = to_regclass('analytics.events_customer_id_idx')
union all select pg_get_indexdef(i.indexrelid) like '%(customer_id)%', 'the index is on customer_id'
from pg_index i where i.indexrelid = to_regclass('analytics.events_customer_id_idx');
