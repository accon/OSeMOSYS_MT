CREATE TABLE policy_target_values
(
  id serial NOT NULL,
  year numeric CHECK (available_capacity > 0 AND available_capacity < 1),
  available_capacity integer,
  power_plant_type_fk integer,
  CONSTRAINT constraint_cap_factor_series_pk PRIMARY KEY (id),
  CONSTRAINT constraint_pp_type_fk FOREIGN KEY (power_plant_type_fk)
      REFERENCES power_plant_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_timestep_fk FOREIGN KEY (timestep_fk)
      REFERENCES timestep (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT capacity_factor_series_available_capacity_check CHECK (available_capacity > 0 AND available_capacity < 1)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE capacity_factor_series
  OWNER TO postgres;
