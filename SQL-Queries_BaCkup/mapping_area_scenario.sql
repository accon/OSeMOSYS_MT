CREATE TABLE mapping_area_scenario
(
  id serial NOT NULL,
  scenario_area_fk integer,
  area_aggregated_fk integer,
  granularity_addition integer,
  CONSTRAINT constraint_map_sc_area_area_agg PRIMARY KEY (id),
  CONSTRAINT constraint_scenario_area_fk FOREIGN KEY (scenario_area_fk)
      REFERENCES scenario_area (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_area_aggregated_fk FOREIGN KEY (area_aggregated_fk)
      REFERENCES area_aggregated (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
COMMENT ON TABLE mapping_area_scenario
  IS 'Putting in place a constraint checking if granularity_addition is possible and giving back an error if numbers >0 are chosen but no areas are given in higher spatial resolution may be advantageous.';
