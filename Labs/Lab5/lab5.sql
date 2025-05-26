-- Diagram 1
-- Every employee mus exist either in the table 'freelancer' or in the table 'permanent'
-- eid must appear in either freelancer or permanent
CREATE TABLE employee(
    eid INTEGER,
    employee_name VARCHAR(80) NOT NULL,
    bdate DATE NOT NULL,
    PRIMARY KEY (eid)
);
-- by omission always put not null
CREATE TABLE department(
    did INTEGER NOT NULL,
    department_name VARCHAR(80) NOT NULL,
    budget NUMERIC(16, 4),
    PRIMARY KEY (did)
);
-- No employee can exist at the same time in the both the table 'freelancer' or in the table 'permanent'
CREATE TABLE freelancer(
    eid INTEGER NOT NULL,
    job VARCHAR(80) NOT NULL,
    hour_rate NUMERIC(16, 4) NOT NULL,
    PRIMARY KEY (eid),
    FOREIGN KEY(eid) REFERENCES employee(eid)
);
CREATE TABLE permanent(
    eid INTEGER NOT NULL,
    speciality VARCHAR(80) NOT NULL,
    PRIMARY KEY (eid),
    FOREIGN KEY(eid) REFERENCES employee(eid)
);
CREATE TABLE works_at(
    eid INTEGER NOT NULL,
    did INTEGER NOT NULL,
    since DATE NOT NULL,
    PRIMARY KEY (eid),
    FOREIGN KEY(eid) REFERENCES employee(eid),
    FOREIGN KEY(did) REFERENCES department(did)
);
CREATE TABLE contract(
    eid INTEGER NOT NULL,
    role VARCHAR(80) NOT NULL,
    salary NUMERIC(16, 4),
    PRIMARY KEY(eid, role),
    FOREIGN KEY(eid) REFERENCES permanent(eid)
);
-- Diagram 2
--Ternary
CREATE TABLE involved_in(
    damage_total NUMERIC(16, 4) NOT NULL,
    report_id INTEGER NOT NULL,
    license CHAR(10) NOT NULL,
    driver_id VARCHAR(10) NOT NULL,
    PRIMARY KEY (report_id, license, driver_id),
    FOREIGN KEY (report_id) REFERENCES Accident(report_id),
    FOREIGN KEY(driver_id) REFERENCES Person (driver_id),
    FOREIGN KEY(license) REFERENCES Car (license)
);
 -- UNIQUE(a,b) combinations of a and b are unique 
-- UNIQUE(a) a is unique 
--Diagram 3
--Recursive
CREATE TABLE requires(
    main_course SMALLINT NOT NULL,
    pre_requisite SMALLINT NOT NULL,
    PRIMARY KEY(main_course, pre_requisite),
    FOREIGN KEY(main_course) REFERENCES course(courseno),
    FOREIGN KEY(pre_requisite) REFERENCES course(courseno),
    CHECK(main_course != pre_requisite)
);

--Diagram 4
--Aggregation

CREATE TABLE supervises(
    name VARCHAR(80) NOT NULL,
    lab_name VARCHAR(200) NOT NULL,
    tin VARCHAR(30) NOT NULL,
    PRIMARY KEY (name,lab_name,tin),
    FOREIGN KEY (tin,lab_name) REFERENCES contract(tin,lab_name),
    FOREIGN KEY (name) REFERENCES supervisor(name)
);

--Diagram 5
-- Mandatory many to one 
-- Relation is collapsed into the entity table which has a mandatory constraint

CREATE TABLE album(
    id INTEGER NOT NULL,
    release_date DATE NOT NULL,
    title VARCHAR(255) NOT NULL,
    idc INTEGER NOT NULL,
    PRIMARY KEY(id),
    FOREIGN KEY(idc) REFERENCES musician(idc)

);

--Extra

CREATE TABLE producer(
    cc INTEGER NOT NULL,
    PRIMARY KEY(cc)
);
-- relationship between producer and an aggregation of produces
CREATE TABLE supervises(
    cc INTEGER NOT NULL,
    id INTEGER NOT NULL,
    PRIMARY KEY (cc,id),
    FOREIGN KEY(id) REFERENCES album(id),
    FOREIGN KEY(cc) REFERENCES producer(cc)
);