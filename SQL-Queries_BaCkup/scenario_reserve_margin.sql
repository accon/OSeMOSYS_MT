CREATE TABLE scenario_reserve_margin
(
  id serial NOT NULL,
  name text,
  CONSTRAINT constraint_screservmar_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);