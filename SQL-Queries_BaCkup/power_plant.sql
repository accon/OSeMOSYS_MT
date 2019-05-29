-- Table: power_plant

DROP TABLE power_plant;

CREATE TABLE power_plant
(
  id serial NOT NULL,
  name text,
  unit_name text,
  owner text,
  owner_type text,
  area_fk integer,
  fuel_fk integer,
  commissioning_year numeric,
  lifetime__a numeric,
  installed_capacity__mw numeric,
  efficiency numeric,
  power_plant_type_fk integer,
  time_ramping_up__min_mw numeric,
  time_ramping_down__min_mw numeric,
  maintenance_time__h_a numeric,
  min_run_time__h numeric,
  start_up_costs__euro numeric,
  secured_capacity__mw numeric,
  grid_connection_level__kv integer,
  optional_fuel_fk integer,
  optional_fuel_2_fk integer,
  annual_production__gwh numeric,
  notes text,
  CONSTRAINT constraint_power_plant_pk PRIMARY KEY (id),
  CONSTRAINT constraint_area_fk FOREIGN KEY (area_fk)
      REFERENCES area (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_fuel_fk FOREIGN KEY (fuel_fk)
      REFERENCES fuel (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_optfuel2_fk FOREIGN KEY (optional_fuel_2_fk)
      REFERENCES fuel (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_optfuel_fk FOREIGN KEY (optional_fuel_fk)
      REFERENCES fuel (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_efficiency_interval CHECK (efficiency >= 0::numeric AND efficiency <= 1::numeric),
  CONSTRAINT power_plant_annual_production__gwh_check CHECK (annual_production__gwh >= 0::numeric),
  CONSTRAINT power_plant_commissioning_year_check CHECK (commissioning_year >= 1850::numeric),
  CONSTRAINT power_plant_installed_capacity__mw_check CHECK (installed_capacity__mw >= 0::numeric),
  CONSTRAINT power_plant_lifetime__a_check CHECK (lifetime__a >= 0::numeric),
  CONSTRAINT power_plant_maintenance_time__h_a_check CHECK (maintenance_time__h_a >= 0::numeric),
  CONSTRAINT power_plant_min_run_time__h_check CHECK (min_run_time__h >= 0::numeric),
  CONSTRAINT power_plant_secured_capacity__mw_check CHECK (secured_capacity__mw >= 0::numeric),
  CONSTRAINT power_plant_start_up_costs__euro_check CHECK (start_up_costs__euro >= 0::numeric),
  CONSTRAINT power_plant_time_ramping_down__min_mw_check CHECK (time_ramping_down__min_mw >= 0::numeric),
  CONSTRAINT power_plant_time_ramping_up__min_mw_check CHECK (time_ramping_up__min_mw >= 0::numeric)
)
WITH (
  OIDS=FALSE
);