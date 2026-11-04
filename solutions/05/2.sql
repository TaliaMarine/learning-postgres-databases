create role lab_05_agent login password 'lab-only';
create table shop.tickets (id integer, owner_name text, subject text);
grant usage on schema shop to lab_05_agent;
grant select on shop.tickets to lab_05_agent;
alter table shop.tickets enable row level security;
create policy own_rows on shop.tickets for select using (owner_name = current_user);
