CREATE TABLE power_plant_emission
(
  id serial NOT NULL,
  power_plant_type_fk integer,
  modelling_year_fk integer,
  emission_factor__tco2e_MWh numeric,
  CONSTRAINT constraint_ppemis_pk PRIMARY KEY (id),
  CONSTRAINT constraint_pptype_fk FOREIGN KEY (power_plant_type_fk)
      REFERENCES power_plant_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_modyr_fk FOREIGN KEY (modelling_year_fk)
      REFERENCES modelling_year (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
  )
WITH (
  OIDS=FALSE
);