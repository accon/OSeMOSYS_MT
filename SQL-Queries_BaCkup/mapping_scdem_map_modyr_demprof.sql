CREATE TABLE mapping_scenario_demand_map_modelling_year_demand_profile
(
  id serial NOT NULL,
  scenario_demand_fk integer,
  mapping_modelling_year_demand_profile_fk integer,
  CONSTRAINT constraint_map_scdem_mapmodyrdemprof PRIMARY KEY (id),
  CONSTRAINT constraint_scdem_fk FOREIGN KEY (scenario_demand_fk)
      REFERENCES scenario_demand (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_mapmodyrdemprof_fk FOREIGN KEY (mapping_modelling_year_demand_profile_fk)
      REFERENCES mapping_modelling_year_demand_profile (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
