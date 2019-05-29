CREATE TABLE mapping_efficiency_scenario
(
  id serial NOT NULL,
  efficiency_fk integer,
  scenario_efficiency_fk integer,
  CONSTRAINT constraint_mapeffscen_pk PRIMARY KEY (id),
  CONSTRAINT constraint_eff_fk FOREIGN KEY (efficiency_fk)
      REFERENCES efficiency (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_sceneffcost_fk FOREIGN KEY (scenario_efficiency_fk)
      REFERENCES scenario_efficiency (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
