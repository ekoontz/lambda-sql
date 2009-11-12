CREATE TABLE station (name TEXT,abbr CHAR(4) PRIMARY KEY);

CREATE TABLE d_before (from_station TEXT,final_destination TEXT, distance INTEGER)");

DROP TABLE IF EXISTS adjacent;

CREATE TABLE adjacent(station_a CHAR(256),station_b CHAR(256));
