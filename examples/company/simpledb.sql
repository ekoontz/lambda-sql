BEGIN TRANSACTION;

CREATE TABLE person (
       person_id SERIAL PRIMARY KEY,
       name TEXT,
       address TEXT
);

CREATE TABLE business_unit (
       business_unit_id SERIAL PRIMARY KEY,
       name,
       address TEXT
);

CREATE SCHEMA finance;

CREATE TABLE finance.project (
       name TEXT,
       project_id SERIAL,
       business_unit_id INTEGER REFERENCES business_unit(business_unit_id),
       manager_id INTEGER REFERENCES person(person_id)      
);	  	     

CREATE SCHEMA software;

CREATE TABLE software.project (
       name TEXT,
       project_id SERIAL,
       business_unit_id INTEGER REFERENCES business_unit(business_unit_id),
       manager_id INTEGER REFERENCES person(person_id)      
);

END TRANSACTION;
