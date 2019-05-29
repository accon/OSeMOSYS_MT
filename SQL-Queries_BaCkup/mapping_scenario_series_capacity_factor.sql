CREATE TABLE mapping_scenario_series_capacity_factor
(
  id serial NOT NULL,
  scenario_series_capacity_factor_fk integer,
  series_capacity_factor_fk integer,
  CONSTRAINT constraint_mapscscf_pk PRIMARY KEY (id),
  CONSTRAINT constraint_scscf_fk FOREIGN KEY (scenario_series_capacity_factor_fk)
      REFERENCES scenario_series_capacity_factor (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_scf_fk FOREIGN KEY (series_capacity_factor_fk)
      REFERENCES series_capacity_factor (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);