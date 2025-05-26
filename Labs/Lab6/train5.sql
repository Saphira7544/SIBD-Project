--1
-- An employee must be either a freelancer or a permanent
create table employee(
    eid integer,
    name varchar(80) not null,
    birthdate date not null,
    constraint pk_employee primary key (eid)
);

create table freelancer(
    eid integer,
    job varchar(80),
    hour_rate numeric(16,4),
    constraint pk_freelancer primary key (eid),
    constraint fk_freelancer_employee foreign key (eid) references employee(eid)
);

create table permanent(
    eid integer,
    speciality varchar(80),
    constraint pk_permanent primary key (eid),
    constraint fk_permanent_employee foreign key (eid) references employee(eid)
);

create table department(
    did integer,
    name varchar(200) not null ,
    budget numeric(16,4) not null,
    constraint pk_department primary key (did)
);

create table contract(
    role varchar(80),
    eid integer,
    salary numeric(16,4) not null,
    constraint pk_contract primary key (role,eid),
    constraint fk_contract_permanent foreign key (eid) references permanent(eid)
);

create table works_at(
  since date not null,
  eid integer unique not null,
  did integer not null,
  constraint pk_works_at primary key (did),
  constraint fk_works_at_department foreign key (did) references department(did),
  constraint fk_works_at_employee foreign key (eid) references employee(eid)
);


-- 2


create table person(
    driver_id varchar(20),
    address varchar(255),
    name varchar(80),
    unique(address,name),
    primary key (driver_id)
);

create table car(
    license varchar(8),
    model varchar(20) not null ,
    year integer not null ,
    primary key (license)
);

create table accident(
    report_id integer,
    location varchar(255) not null ,
    date date not null,
    primary key (report_id)
);

create table owns(
    driver_id varchar(20),
    license varchar(8),
    primary key (driver_id),
    foreign key (driver_id) references person(driver_id),
    foreign key (license) references car(license)
);

create table involved_in(
    damage_total numeric(16,4),
    license varchar(8),
    driver_id varchar(20),
    report_id integer,
    primary key (license,driver_id,report_id),
    foreign key (report_id) references accident(report_id),
    foreign key (driver_id) references person(driver_id),
    foreign key (license) references car(license)
);


-- 3

create table course(

);
