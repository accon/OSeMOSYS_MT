CREATE TABLE scenario_capacity_restrictions
(
  id serial NOT NULL,
  name text,
  CONSTRAINT constraint_sccaprestr_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);