CREATE TABLE mapping_modelling_set_modelling_year
(
  id serial NOT NULL,
  modelling_set_modelling_year_fk integer,
  modelling_year_fk integer,
  CONSTRAINT constraint_map_modset_modyr_pk PRIMARY KEY (id),
  CONSTRAINT constraint_modset_modyr_fk FOREIGN KEY (modelling_set_modelling_year_fk)
      REFERENCES modelling_set_modelling_year (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_modyr_fk FOREIGN KEY (modelling_year_fk)
      REFERENCES modelling_year (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
