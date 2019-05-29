CREATE TABLE scenario_power_plant_existing
(
  id serial NOT NULL,
  name text,
  CONSTRAINT constraint_scenppexist_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);