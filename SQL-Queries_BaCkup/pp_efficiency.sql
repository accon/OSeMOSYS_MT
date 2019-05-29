-- Table: efficiency

DROP TABLE efficiency;

CREATE TABLE power_plant_efficiency
(
  id serial NOT NULL,
  power_plant_type_fk integer,
  modelling_year_fk integer,
  efficiency numeric,
  CONSTRAINT constraint_eff_pk PRIMARY KEY (id),
  CONSTRAINT constraint_modyr_fk FOREIGN KEY (modelling_year_fk)
      REFERENCES modelling_year (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_pptype_fk FOREIGN KEY (power_plant_type_fk)
      REFERENCES power_plant_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);