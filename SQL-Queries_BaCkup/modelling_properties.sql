CREATE TABLE modelling_run_properties
(
  id integer NOT NULL DEFAULT nextval('modelling_year_pk_seq'::regclass),
  scenario_area_fk integer,
  scenario_efficiency_fk integer,
  scenario_fuel_cost_fk integer,
  scenario_power_plant_cost_fk integer,
  scenario_storage_cost_fk integer,
  scenario_time_fk integer,
  modelling_set_emission_fk integer,
  modelling_set_fuel_fk integer,
  modelling_set_modelling_year_fk integer

  CONSTRAINT modelling_year_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE modelling_year
  OWNER TO dbuser;
