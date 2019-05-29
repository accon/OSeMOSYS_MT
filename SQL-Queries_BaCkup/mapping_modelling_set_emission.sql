CREATE TABLE mapping_modelling_set_emission
(
  id serial NOT NULL,
  modelling_set_emission_fk integer,
  emission_fk integer,
  CONSTRAINT constraint_map_mod_set_emission_pk PRIMARY KEY (id),
  CONSTRAINT constraint_emission_fk FOREIGN KEY (emission_fk)
      REFERENCES emission (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_mod_set_emission_fk FOREIGN KEY (modelling_set_emission_fk)
      REFERENCES modelling_set_emission (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
