CREATE TABLE scenario_demand
(
  id serial NOT NULL,
  name text,
  CONSTRAINT constraint_demsc_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
