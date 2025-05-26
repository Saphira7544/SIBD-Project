-------------------------------------------------------------
-- Project Assignment - Part 3 - Schema
-------------------------------------------------------------
DROP TABLE IF EXISTS analyses cascade;
DROP TABLE IF EXISTS lineincident cascade;
DROP TABLE IF EXISTS incident cascade;
DROP TABLE IF EXISTS transformer  cascade;
DROP TABLE IF EXISTS line cascade;
DROP TABLE IF EXISTS busbar cascade;
DROP TABLE IF EXISTS element cascade;
DROP TABLE IF EXISTS substation cascade;
DROP TABLE IF EXISTS analyst cascade;
DROP TABLE IF EXISTS supervisor cascade;
DROP TABLE IF EXISTS person cascade;

CREATE TABLE person(
    name VARCHAR(80),
    address VARCHAR(80),
    phone NUMERIC(9),
    taxid NUMERIC(20),
	PRIMARY KEY(name, address),
	UNIQUE(phone),
	UNIQUE(taxid)
);

CREATE TABLE supervisor(
	name VARCHAR(80),
    address VARCHAR(80),
	PRIMARY KEY(name, address),
	FOREIGN KEY(name, address) REFERENCES person(name, address)
);

CREATE TABLE analyst(
	name VARCHAR(80),
    address VARCHAR(80),
	PRIMARY KEY(name, address),
	FOREIGN KEY(name, address) REFERENCES person(name, address)
);

CREATE TABLE substation(
    gpslat NUMERIC(9,6),
    gpslong NUMERIC(8,6),
    locality VARCHAR(80),
    sname VARCHAR(80),
    saddress VARCHAR(80),
    PRIMARY KEY(gpslat, gpslong),
    FOREIGN KEY(sname, saddress) REFERENCES supervisor(name, address)
);

CREATE TABLE element(
    id VARCHAR(10),
    PRIMARY KEY(id)
);

CREATE TABLE busbar(
    id VARCHAR(10),
    voltage NUMERIC(7,4),
    PRIMARY KEY(id),
    FOREIGN KEY(id) REFERENCES element(id)
);

CREATE TABLE transformer(
    id VARCHAR(10),
    pv NUMERIC(7, 4),
    sv NUMERIC(7, 4),
    gpslat NUMERIC(9,6),
    gpslong NUMERIC(8,6),
    pbbid VARCHAR(10),
    sbbid VARCHAR(10),
    PRIMARY KEY(id),
    FOREIGN KEY(id) REFERENCES element(id),
    FOREIGN KEY(gpslat, gpslong) REFERENCES substation(gpslat, gpslong),
    FOREIGN KEY(pbbid) REFERENCES busbar(id),
    FOREIGN KEY(sbbid) REFERENCES busbar(id),
    CHECK(pbbid<>sbbid)
);

CREATE TABLE line(
    id VARCHAR(10),
    impedance NUMERIC(7,4),
    pbbid VARCHAR(10),
    sbbid VARCHAR(10),
    PRIMARY KEY(id),
    FOREIGN KEY(id) REFERENCES element(id),
    FOREIGN KEY(pbbid) REFERENCES busbar(id),
    FOREIGN KEY(sbbid) REFERENCES busbar(id),
    CHECK(pbbid<>sbbid)
);

CREATE TABLE incident(
    instant TIMESTAMP,
    id VARCHAR(10),
    description VARCHAR(250),
    severity VARCHAR(30),
    PRIMARY KEY(instant, id),
    FOREIGN KEY(id) REFERENCES element(id)
);

CREATE TABLE lineincident(
    instant TIMESTAMP,
    id VARCHAR(10),
    point FLOAT,
    PRIMARY KEY(instant, id),
    FOREIGN KEY(instant, id) REFERENCES incident(instant, id)
);

CREATE TABLE analyses(
    instant TIMESTAMP,
    id VARCHAR(10),
    report VARCHAR(255),
	name VARCHAR(80),
    address VARCHAR(80),
    PRIMARY KEY(instant, id),
    FOREIGN KEY(instant, id) REFERENCES incident(instant, id),
    FOREIGN KEY(name, address) REFERENCES analyst(name, address)
);