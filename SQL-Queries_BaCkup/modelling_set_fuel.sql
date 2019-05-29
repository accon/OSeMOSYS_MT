CREATE TABLE modelling_set_fuel
(
  id integer NOT NULL DEFAULT nextval('modelling_year_pk_seq'::regclass),
  name text,
  CONSTRAINT modelling_set_fuel_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
