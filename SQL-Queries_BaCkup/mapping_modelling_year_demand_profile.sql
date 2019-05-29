CREATE TABLE mapping_modelling_year_demand_profile
(
  id serial NOT NULL,
  modelling_year_fk integer,
  demand_profile_fk integer,
  CONSTRAINT constraint_map_modyr_demprof PRIMARY KEY (id),
  CONSTRAINT constraint_modyr_fk FOREIGN KEY (modelling_year_fk)
      REFERENCES modelling_year (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_demprof_fk FOREIGN KEY (demand_profile_fk)
      REFERENCES demand_profile (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
