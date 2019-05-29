CREATE TABLE mapping_storage_cost_scenario
(
  id serial NOT NULL,
  storage_cost_fk integer,
  scenario_storage_cost_fk integer,
  CONSTRAINT constraint_mapstorcostscen_pk PRIMARY KEY (id),
  CONSTRAINT constraint_storcost_fk FOREIGN KEY (storage_cost_fk)
      REFERENCES storage_cost (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_scenstorcost_fk FOREIGN KEY (scenario_storage_cost_fk)
      REFERENCES scenario_storage_cost (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
