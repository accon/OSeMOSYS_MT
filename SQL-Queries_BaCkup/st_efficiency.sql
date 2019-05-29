-- Table: efficiency
CREATE TABLE storage_efficiency
(
  id serial NOT NULL,
  storage_type_fk integer,
  modelling_year_fk integer,
  charge_efficiency numeric,
  discharge_efficiency numeric,
  CONSTRAINT constraint_steff_pk PRIMARY KEY (id),
  CONSTRAINT constraint_modyr_fk FOREIGN KEY (modelling_year_fk)
      REFERENCES modelling_year (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_sttype_fk FOREIGN KEY (storage_type_fk)
      REFERENCES storage_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);