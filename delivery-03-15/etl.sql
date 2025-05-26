-- Load Dimensional Tables

-- d_time table loading will be done through a function
CREATE OR REPLACE FUNCTION load_time_dim()
    RETURNS VOID AS
$$
DECLARE
    time_value TIMESTAMP;
BEGIN
    time_value := '2015-01-01 00:00:00'; -- Starting point of the time axis
    WHILE time_value < '2030-01-01 00:00:00' -- End point of the time axis
        LOOP
            INSERT INTO d_time(year, trimester, month, week, week_day, day)
            VALUES (EXTRACT(YEAR FROM time_value), -- take year
                    CASE -- take trimester
                        WHEN EXTRACT(MONTH FROM time_value) <= 3 THEN 1
                        WHEN EXTRACT(MONTH FROM time_value) BETWEEN 3 AND 6 THEN 2
                        WHEN EXTRACT(MONTH FROM time_value) BETWEEN 6 AND 9 THEN 3
                        ELSE 4
                        END,
                    CAST(EXTRACT(MONTH FROM time_value) AS INTEGER), -- take month
                    CAST(EXTRACT(WEEK FROM time_value) AS INTEGER), -- take week
                    TO_CHAR(time_value, 'Day'), -- take day name
                    CAST(EXTRACT(DAY FROM time_value) AS INTEGER)); -- take day number
            time_value := time_value + INTERVAL '1 DAY';
        END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT load_time_dim();


-- Load the d_reporter table from operational table Analyst

CREATE OR REPLACE FUNCTION load_reporter_dim()
    RETURNS VOID AS
$$
BEGIN
    INSERT INTO d_reporter(name, address)
    SELECT name, address
    from analyst;

END;
$$ LANGUAGE plpgsql;

SELECT load_reporter_dim();

-- Load the d_location table from operational table Substation

CREATE OR REPLACE FUNCTION load_location_dim()
    RETURNS VOID AS
$$
BEGIN
    -- 1st Entry for the Line and Busbar unknown location
    INSERT INTO d_location(latitude, longitude, locality) VALUES (0,0,'Unknown');
    INSERT INTO d_location(latitude, longitude, locality)
    SELECT gpslat as latitude, gpslong as longitude, locality
    from substation;

END;
$$ LANGUAGE plpgsql;

SELECT load_location_dim();
-- Load the d_element table from operational table Element
CREATE OR REPLACE FUNCTION load_element_dim()
    RETURNS VOID AS
$$
BEGIN
        INSERT INTO d_element(element_id, element_type)
        SELECT id,
               CASE WHEN id IN (SELECT id from busbar) THEN 'busbar'
                    WHEN id IN (SELECT id from transformer) THEN 'transformer'
                    WHEN id IN (SELECT  id from line) THEN 'line'
                END AS element_type
        from element;

END;
$$ LANGUAGE plpgsql;

SELECT  load_element_dim();


-- Load Fact table
-- Using LEFT OUTER JOIN with the dimension tables since that's the way the theoretical class powerpoints do it
-- But we can also use INNER JOIN, the result is the same

-- transfromer incidents
INSERT INTO f_incident(id_reporter, id_time, id_location, id_element, severity)
SELECT id_reporter, id_time, id_location, id_element, severity
FROM (incident NATURAL JOIN analyses
               NATURAL JOIN transformer) AS i
         LEFT OUTER JOIN d_reporter r
                         ON r.name = i.name AND r.address = i.address
         LEFT OUTER JOIN d_location l
                         ON l.latitude = i.gpslat AND l.longitude = i.gpslong
         LEFT OUTER JOIN d_element e
                         ON e.element_id = i.id
         LEFT OUTER JOIN d_time t
                         ON t.day = EXTRACT(DAY FROM i.instant) AND t.month = EXTRACT(MONTH FROM i.instant) AND
                            t.year = EXTRACT(YEAR FROM i.instant);

-- busbar incidents
INSERT INTO f_incident(id_reporter, id_time, id_location, id_element, severity)
SELECT id_reporter, id_time, 1, id_element, severity
FROM (incident NATURAL JOIN analyses
               NATURAL JOIN busbar) AS i
         LEFT OUTER JOIN d_reporter r
                         ON r.name = i.name AND r.address = i.address
         LEFT OUTER JOIN d_element e
                         ON e.element_id = i.id
         LEFT OUTER JOIN d_time t
                         ON t.day = EXTRACT(DAY FROM i.instant) AND t.month = EXTRACT(MONTH FROM i.instant) AND
                            t.year = EXTRACT(YEAR FROM i.instant);

-- line incidents
INSERT INTO f_incident(id_reporter, id_time, id_location, id_element, severity)
SELECT id_reporter, id_time, 1, id_element, severity
FROM (incident NATURAL JOIN analyses
               NATURAL JOIN line) as i
         LEFT OUTER JOIN d_reporter r
                         ON r.name = i.name AND r.address = i.address
         LEFT OUTER JOIN d_element e
                         ON e.element_id = i.id
         LEFT OUTER JOIN d_time t
                         ON t.day = EXTRACT(DAY FROM i.instant) AND t.month = EXTRACT(MONTH FROM i.instant) AND
                            t.year = EXTRACT(YEAR FROM i.instant);