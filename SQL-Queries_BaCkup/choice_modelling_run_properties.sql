CREATE TABLE choice_modelling_run_properties
(
  id serial NOT NULL,
  modelling_run_properties_fk integer,
  CONSTRAINT constraint_chmodrunprop_pk PRIMARY KEY (id),
  CONSTRAINT constraint_modrunprop_fk FOREIGN KEY (id)
      REFERENCES modelling_run_properties (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
