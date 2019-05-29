CREATE TABLE mapping_power_plant_cost_scenario
(
  id serial NOT NULL,
  power_plant_cost_fk integer,
  scenario_power_plant_cost_fk integer,
  CONSTRAINT constraint_mapppcostscen_pk PRIMARY KEY (id),
  CONSTRAINT constraint_ppcost_fk FOREIGN KEY (power_plant_cost_fk)
      REFERENCES power_plant_cost (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_scenppcost_fk FOREIGN KEY (scenario_power_plant_cost_fk)
      REFERENCES scenario_power_plant_cost (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
