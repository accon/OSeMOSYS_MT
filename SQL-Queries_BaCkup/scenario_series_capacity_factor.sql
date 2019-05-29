CREATE TABLE scenario_series_capacity_factor
(
  id serial NOT NULL,
  name text,
  CONSTRAINT constraint_scscf_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);