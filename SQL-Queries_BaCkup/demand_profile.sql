CREATE TABLE demand_profile
(
  id serial NOT NULL,
  timestep_fk integer,
  area_fk integer,
  demand_normalized numeric CHECK (demand_normalized > 0 AND demand_normalized < 1),
  demand_type_fk integer,
  CONSTRAINT constraint_demand_prof_pk PRIMARY KEY (id),
  CONSTRAINT constraint_timestep_fk FOREIGN KEY (timestep_fk)
      REFERENCES timestep (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_area_fk FOREIGN KEY (area_fk)
      REFERENCES area (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_demand_type_fk FOREIGN KEY (power_plant_type_fk)
      REFERENCES demand_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION 
)
WITH (
  OIDS=FALSE
);
