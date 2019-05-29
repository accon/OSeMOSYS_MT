CREATE TABLE mapping_scenario_capacity_restrictions
(
  id serial NOT NULL,
  scenario_capacity_restrictions_fk integer,
  modelling_annual_capacity_restrictions_fk integer,
  CONSTRAINT constraint_mapsccaprestr_pk PRIMARY KEY (id),
  CONSTRAINT constraint_sccaprestr_fk FOREIGN KEY (scenario_capacity_restrictions_fk)
      REFERENCES scenario_capacity_restrictions (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_scmodanncaprestr_fk FOREIGN KEY (modelling_annual_capacity_restrictions_fk)
      REFERENCES modelling_annual_capacity_restrictions (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
