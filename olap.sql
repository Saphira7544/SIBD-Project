SELECT COALESCE(severity, 'All Severities') as severity, COALESCE(locality, 'All Locations') as locality, COALESCE(week_day, 'All Days') as week_day, COUNT(*)
FROM f_incident NATURAL JOIN d_location NATURAL JOIN d_time
GROUP BY CUBE(severity, locality,week_day)
ORDER BY (severity, locality, week_day) DESC;