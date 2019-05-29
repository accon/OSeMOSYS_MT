-- Table: mapping_efficiency_scenario

DROP TABLE mapping_efficiency_scenario;

CREATE TABLE mapping_scenario_efficiency
(
  id serial NOT NULL,
  scenario_efficiency_fk integer,
  power_plant_efficiency_fk integer,
  storage_efficiency_fk integer,
  CONSTRAINT constraint_mapsceneff_pk PRIMARY KEY (id),
  CONSTRAINT constraint_sceneff_fk FOREIGN KEY (scenario_efficiency_fk)
      REFERENCES scenario_efficiency (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_ppeff_fk FOREIGN KEY (power_plant_efficiency_fk)
      REFERENCES power_plant_efficiency (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_steff_fk FOREIGN KEY (storage_efficiency_fk)
      REFERENCES storage_efficiency (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
      
)
WITH (
  OIDS=FALSE
);
