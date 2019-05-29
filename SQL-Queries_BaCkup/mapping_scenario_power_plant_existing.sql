CREATE TABLE mapping_scenario_power_plant_existing
(
  id serial NOT NULL,
  scenario_power_plant_existing_fk integer,
  power_plant_fk integer,
  CONSTRAINT constraint_map_scppexist_pk PRIMARY KEY (id),
  CONSTRAINT constraint_scppexist_fk FOREIGN KEY (scenario_power_plant_existing_fk)
      REFERENCES scenario_power_plant_existing (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_pp_fk FOREIGN KEY (power_plant_fk)
      REFERENCES power_plant (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
