BEGIN TRANSACTION;

CREATE TABLE contact (
       contact_id SERIAL PRIMARY KEY,
       name TEXT
);

CREATE TABLE location (
       location_id SERIAL PRIMARY KEY,
       street_number TEXT,
       street TEXT
);


CREATE SCHEMA finance;

CREATE TABLE finance.project (
       name TEXT,
       project_id SERIAL,
       location_id INTEGER REFERENCES location(location_id),
       manager_id INTEGER REFERENCES contact(contact_id)      
);	  	     

CREATE SCHEMA software;

CREATE TABLE software.project (
       name TEXT,
       project_id SERIAL,
       location_id INTEGER REFERENCES location(location_id),
       manager_id INTEGER REFERENCES contact(contact_id)      
);

END TRANSACTION;
