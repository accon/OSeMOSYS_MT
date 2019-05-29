DROP TABLE area_scenario;

CREATE TABLE scenario_area
(
  id serial NOT NULL,
  area_aggregated_fk integer,
  granularity_addition integer,
  CONSTRAINT constraint_area_scenario_pk PRIMARY KEY (id),
  CONSTRAINT constraint_area_aggregated_fk FOREIGN KEY (area_aggregated_fk)
      REFERENCES area_aggregated (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
COMMENT ON TABLE scenario_area
  IS 'Putting in place a constraint checking if granularity_addition is possible and giving back an error if numbers >0 are chosen but no areas are given in higher spatial resolution may be advantageous.';
