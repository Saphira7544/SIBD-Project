--1)
SELECT AVG(reading), dd.week_day_name
from meter_readings m
         INNER JOIN date_dimension dd on m.date_id = dd.date_id
GROUP BY dd.week_day_name;
-- class sol
SELECT week_day_name, AVG(reading)
FROM meter_readings
         NATURAL JOIN date_dimension
GROUP BY week_day_name
ORDER BY AVG(reading) DESC;

--2)
SELECT AVG(reading), dd.week_number, bd.building_name
FROM meter_readings m
         INNER JOIN date_dimension dd on m.date_id = dd.date_id
         INNER JOIN building_dimension bd on m.building_id = bd.building_id
WHERE dd.week_number > 49 -- last 3 weeks of a year
GROUP BY dd.week_number, bd.building_name;

--3)
SELECT AVG(reading), dd.week_number, bd.building_name
FROM meter_readings m
         INNER JOIN date_dimension dd on m.date_id = dd.date_id
         INNER JOIN building_dimension bd on m.building_id = bd.building_id
WHERE dd.week_number > 49 -- last 3 weeks of a year
GROUP BY ROLLUP (dd.week_number, bd.building_name);
-- class sol
SELECT week_number, AVG(reading)
FROM meter_readings
         NATURAL JOIN date_dimension
WHERE week_number >= 50
GROUP BY week_number
ORDER BY week_number ASC;

-- COALESCE can be used for getting ALLDAYS or ALLBUILDINGS cast must be used to switch datatype

SELECT COALESCE(building_name, 'ALL BUILDINGS'),
   	COALESCE(cast(week_number as varchar), 'ALL WEEKS'), AVG(reading)
FROM meter_readings NATURAL JOIN building_dimension NATURAL JOIN date_dimension
WHERE week_number>=50
GROUP BY ROLLUP (week_number,building_name)
ORDER BY building_name, week_number DESC;

--4)
SELECT AVG(reading), bd.building_name
FROM meter_readings m
         INNER JOIN building_dimension bd on m.building_id = bd.building_id
GROUP BY bd.building_name
ORDER BY AVG(reading) DESC;

--5)
SELECT AVG(reading), bd.building_name, dd.week_day_name
FROM meter_readings m
         INNER JOIN date_dimension dd on m.date_id = dd.date_id
         INNER JOIN building_dimension bd on m.building_id = bd.building_id
GROUP BY ROLLUP (bd.building_name, dd.week_day_name)
ORDER BY AVG(reading) DESC;

--6)
SELECT AVG(reading), bd.building_name, td.day_period
FROM meter_readings m
         INNER JOIN time_dimension td on m.time_id = td.time_id
         INNER JOIN building_dimension bd on m.building_id = bd.building_id
GROUP BY ROLLUP (bd.building_id, td.day_period)
ORDER BY AVG(reading) DESC;

--7)
SELECT AVG(reading), bd.building_name, td.day_period, td.hour_of_day
FROM meter_readings m
         INNER JOIN time_dimension td on m.time_id = td.time_id
         INNER JOIN building_dimension bd on m.building_id = bd.building_id
GROUP BY ROLLUP (bd.building_name, td.day_period, td.hour_of_day)
ORDER BY hour_of_day, day_period,building_name DESC;

--8)

DROP TABLE IF EXISTS results;

CREATE TABLE results
(
    building_name VARCHAR(20),
    day_period    VARCHAR(20),
    hour_of_day   INTEGER,
    avg_reading   DOUBLE PRECISION
);

INSERT INTO results
SELECT bd.building_name, td.day_period, td.hour_of_day, AVG(reading)
FROM meter_readings m
         INNER JOIN time_dimension td on m.time_id = td.time_id
         INNER JOIN building_dimension bd on m.building_id = bd.building_id
GROUP BY ROLLUP (bd.building_name, td.day_period, td.hour_of_day)
ORDER BY hour_of_day, day_period,building_name  DESC;


SELECT AVG(avg_reading), day_period
FROM results
WHERE day_period IS NOT NULL
  AND hour_of_day IS NOT NULL
GROUP BY day_period
HAVING AVG(avg_reading) >
       (SELECT avg_reading FROM results WHERE day_period IS NULL AND building_name IS NULL AND hour_of_day IS NULL);

-- Faster better solution
SELECT AVG(avg_reading), day_period
FROM results
WHERE day_period IS NOT NULL  AND hour_of_day IS NULL
GROUP BY day_period
HAVING AVG(avg_reading) >
       (SELECT avg_reading
        FROM results
        WHERE building_name IS NULL);


/* Exa
SELECT building_name, week_number, AVG(reading)
FROM meter_readings NATURAL JOIN building_dimension NATURAL JOIN date_dimension
WHERE week_number >= 50
GROUP BY ROLLUP (week_number, building_name)
ORDER BY building_name, week_number ASC;

SELECT week_number, building_name, AVG(reading)
FROM meter_readings NATURAL JOIN building_dimension NATURAL JOIN date_dimension
WHERE week_number>=50
GROUP BY GROUPING SETS ((week_number,building_name),(week_number),())
ORDER BY building_name, week_number DESC;

	select building_name, week_number, avg(reading) as consumption
	from meter_readings
		natural join date_dimension
		natural join building_dimension
	where week_number >= 50
	group by building_name, week_number
	UNION
	select ‘ALL Buildings’, week_number, avg(reading) as consumption
	from meter_readings
		natural join date_dimension
	where week_number >= 50
	group by week_number
	UNION
	select ‘ALL Buildings’, ‘ALL Weeks’, avg(reading) as consumption
	from meter_readings
		natural join date_dimension
	where week_number >= 50
*/