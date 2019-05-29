CREATE TABLE emission
(
  id serial NOT NULL,
  name text,
  CONSTRAINT constraint_emission_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

