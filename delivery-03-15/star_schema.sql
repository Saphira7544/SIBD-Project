DROP TABLE IF EXISTS f_incident;
DROP TABLE IF EXISTS d_time;
DROP TABLE IF EXISTS d_location;
DROP TABLE IF EXISTS d_element;
DROP TABLE IF EXISTS d_reporter;

-- Reporter Dimension table
CREATE TABLE d_reporter(
    id_reporter SERIAL,
    name VARCHAR(80) NOT NULL,
    address VARCHAR(80) NOT NULL,
    PRIMARY KEY (id_reporter)
);

-- Time Dimension table
CREATE TABLE d_time(
    id_time SERIAL,
    day INTEGER NOT NULL,
    week_day VARCHAR(9) NOT NULL,
    week INTEGER NOT NULL,
    month INTEGER NOT NULL,
    trimester INTEGER NOT NULL,
    year INTEGER NOT NULL,
    PRIMARY KEY(id_time)
);

-- Location Dimension table
CREATE TABLE d_location(
    id_location SERIAL,
    latitude NUMERIC(9,6) NOT NULL,
    longitude NUMERIC(8,6) NOT NULL,
    locality VARCHAR(80) NOT NULL,
    PRIMARY KEY (id_location)
);

-- Element dimension table
CREATE TABLE d_element(
    id_element SERIAL,
    element_id VARCHAR(10) NOT NULL,
    element_type VARCHAR(15) NOT NULL,
    PRIMARY KEY (id_element)
);

-- Fact table
CREATE TABLE f_incident(
    id_reporter INTEGER,
    id_time INTEGER,
    id_location INTEGER,
    id_element INTEGER,
    severity VARCHAR(30) NOT NULL,
    PRIMARY KEY (id_reporter, id_time, id_location, id_element),
    -- Since data is consistent, foreign keys could be removed for optimization purposes, but we insert them to guarantee referential integrity
    FOREIGN KEY (id_reporter) REFERENCES d_reporter(id_reporter),
    FOREIGN KEY (id_time) REFERENCES d_time(id_time),
    FOREIGN KEY (id_element) REFERENCES d_element(id_element),
    FOREIGN KEY (id_location) REFERENCES  d_location(id_location)
);

-- Since there is no time dimension we are considering no incident can occur at the same time, in the same element and be reported by the same analyst