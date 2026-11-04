create statistics lab_ev_device on (payload ->> 'device') from analytics.events;
analyze analytics.events;
