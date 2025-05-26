
--6.1
CREATE INDEX ON substation(locality);
CREATE INDEX ON transformer USING HASH(pv);
--6.2
CREATE INDEX ON incident(instant, id, description);