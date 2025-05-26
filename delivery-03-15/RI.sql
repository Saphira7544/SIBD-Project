-- IC1 and IC2 implementation
ALTER TABLE busbar
    ADD CONSTRAINT unique_c UNIQUE(id, voltage); -- must add this for next operatyion to work.
ALTER TABLE transformer
    -- if wanted uncomment the the next to lines to drop the previous foreign key constraints
    --DROP CONSTRAINT transformer_pbbid_fkey,
    --DROP CONSTRAINT transformer_sbbid_fkey,
    ADD CONSTRAINT transformer_pbb_fkey FOREIGN KEY (pbbid, pv) REFERENCES busbar(id, voltage), -- add the voltage to the busbar id constraint
    ADD CONSTRAINT transformer_sbb_fkey FOREIGN KEY (sbbid, sv) REFERENCES busbar(id, voltage); -- this way the busbar voltage must match the transformer voltage



-- IC5 constraint implementation
DROP TRIGGER IF EXISTS IC_5 on analyses;

create or replace function check_substation() returns trigger as
$$
declare
    t_id VARCHAR(10); -- transformer id
    lat  NUMERIC(9, 6); -- latitude of transformer's substation
    long NUMERIC(8, 6); -- longitude of transformer's substation
    sn   VARCHAR(80); -- name of substation supervisor
    sa   VARCHAR(80); -- address of substation supervisor
begin
    if new.id IN (select id from transformer) then -- If the element is a transformer we need to check
        t_id := new.id; -- save element id
        -- Get the coordinates and supervisor data corresponding to the transformer in the incident
        select s.sname, s.saddress, t.gpslat, t.gpslong
        from transformer t
                 inner join substation s on s.gpslat = t.gpslat and s.gpslong = t.gpslong
        where t.id = t_id
        into sn,sa,lat,long;
        if new.name = sn and new.address=sa then -- If they are the same then the integrity constrsint was violated
            raise exception 'Analyst cannot analyse incident since it belongs to one of the substations he supervises';
        end if;
    end if;
    return new;

end;
$$ language plpgsql;

create TRIGGER IC_5
    before -- Similarly to before the after or before is irrelevant.
        update or insert
    on analyses
    for each row
execute procedure check_substation();

-- Just add a check to the coordinates of the substation so that there are no invalid coordinates
ALTER TABLE substation
ADD CONSTRAINT long_lat_range_check
CHECK (
	gpslong BETWEEN -90 AND 90
	AND gpslat BETWEEN -180 AND 180
);
-- Working with longitude and latitude ranges switched to not alter the schemaPart3.sql

