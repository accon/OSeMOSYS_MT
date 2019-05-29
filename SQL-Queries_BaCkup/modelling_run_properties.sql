CREATE TABLE modelling_run_properties
(
  id integer,
  modelling_run_name text,
  scenario_area_fk integer,
  scenario_efficiency_fk integer,
  scenario_fuel_cost_fk integer,
  scenario_power_plant_cost_fk integer,
  scenario_storage_cost_fk integer,
  scenario_time_fk integer,
  modelling_set_emission_fk integer,
  modelling_set_fuel_fk integer,
  modelling_set_modelling_year_fk integer,
  CONSTRAINT modelling_run_properties_pk PRIMARY KEY (id),
  CONSTRAINT constraint_scarea_fk FOREIGN KEY (scenario_area_fk)
      REFERENCES scenario_area (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_sceff_fk FOREIGN KEY (scenario_efficiency_fk)
      REFERENCES scenario_efficiency (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_scfuelcost_fk FOREIGN KEY (scenario_fuel_cost_fk)
      REFERENCES scenario_fuel_cost (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_scppcost_fk FOREIGN KEY (scenario_power_plant_cost_fk)
      REFERENCES scenario_power_plant_cost (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_scstorcost_fk FOREIGN KEY (scenario_storage_cost_fk)
      REFERENCES scenario_storage_cost (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_sctime_fk FOREIGN KEY (scenario_time_fk)
      REFERENCES scenario_time (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_modsetemiss_fk FOREIGN KEY (modelling_set_emission_fk)
      REFERENCES modelling_set_emission (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_modsetfuel_fk FOREIGN KEY (modelling_set_fuel_fk)
      REFERENCES modelling_set_fuel (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_modsetmodyr_fk FOREIGN KEY (modelling_set_modelling_year_fk)
      REFERENCES modelling_set_modelling_year (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
