DROP TABLE scenario_area;

CREATE TABLE scenario_area
(
  id serial NOT NULL,
  name text,
  CONSTRAINT constraint_area_scenario_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

