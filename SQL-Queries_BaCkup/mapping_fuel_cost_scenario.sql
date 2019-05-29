CREATE TABLE mapping_fuel_cost_scenario
(
  id serial NOT NULL,
  fuel_cost_fk integer,
  scenario_fuel_cost_fk integer,
  CONSTRAINT constraint_mapfuelcostscen_pk PRIMARY KEY (id),
  CONSTRAINT constraint_fuel_cost_fk FOREIGN KEY (fuel_cost_fk)
      REFERENCES fuel_cost (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_scenfuelcost_fk FOREIGN KEY (scenario_fuel_cost_fk)
      REFERENCES scenario_fuel_cost (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
