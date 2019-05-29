CREATE TABLE modelling_set_emission
(
  id integer NOT NULL DEFAULT nextval('modelling_year_pk_seq'::regclass),
  name text,
  CONSTRAINT modelling_set_emission_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
