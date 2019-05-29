CREATE TABLE mapping_scenario_emission
(
  id serial NOT NULL,
  scenario_emission_fk integer,
  power_plant_emission_fk integer,
  CONSTRAINT constraint_mapscenemis_pk PRIMARY KEY (id),
  CONSTRAINT constraint_ppemis_fk FOREIGN KEY (power_plant_emission_fk)
      REFERENCES power_plant_emission (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_scenemis_fk FOREIGN KEY (scenario_emission_fk)
      REFERENCES scenario_emission (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
