CREATE TABLE mapping_demand_profile_value
(
  id serial NOT NULL,
  demand_profile_fk integer,
  demand_profile_value_fk integer,
  CONSTRAINT constraint_map_demprof_val PRIMARY KEY (id),
  CONSTRAINT constraint_demprof_fk FOREIGN KEY (demand_profile_fk)
      REFERENCES demand_profile (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_demprof_val_fk FOREIGN KEY (demand_profile_value_fk)
      REFERENCES demand_profile_value (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);