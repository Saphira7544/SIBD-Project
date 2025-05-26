-- 3 - View   --
CREATE VIEW supp(sname, saddress, num_subs)
AS
SELECT sname, saddress, COUNT(*) AS num_subs
FROM substation
GROUP BY sname, saddress;

-- 4 - SQL Queries --

-- 1 --
-- Analysts that have analysed every incident of element B-789
select a.name, a.address
from analyst a
where not exists(select id,
                        instant -- Every incidents on 'B-789'
                 from incident
                 where id = 'B-789'
                     except
                 select id,
                        instant -- every incident analysed by the analyst in question
                 from analyses an
                 where an.name = a.name
                   and an.address = a.address)
;

-- 2 --
--Supervisors that do not supervise substations south of Rio Maior. (Must be supervising at least one substation to be elligible)
SELECT DISTINCT sname, saddress
FROM substation
WHERE (sname, saddress) NOT IN (
    SELECT sname,
           saddress -- supervisors from substations south of Rio Maior
    FROM substation
    WHERE gpslat <= 39.336775); -- Latitude coordinate of Rio Maior

-- 3 --
-- Elements with the smallest amount of incidents (element must have atleast one incident to be elligible)
SELECT id, COUNT(id)
FROM incident -- ids come from the incident substation (we don't want elements with 0 incidents)
GROUP BY id
HAVING COUNT(id) <= ALL ( -- Elements that less or equal number of incidents than the rest of the elements
    SELECT COUNT(i2.id)
    FROM incident i2
    GROUP BY i2.id);

-- 4 --
-- How many substations does each supervisor supervise
SELECT name, address, COALESCE(num_subs, 0)
FROM supervisor s -- Needs base table due to the supervisors with no substations
         LEFT OUTER JOIN supp ON s.name = supp.sname AND s.address = supp.saddress; -- Use the view created to get all the counts

