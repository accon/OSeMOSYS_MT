CREATE TABLE fuel_cost
(
  id serial NOT NULL,
  fuel_fk integer,
  modelling_year_fk integer,
  specific_costs__euro_MWh numeric check (specific_costs__euro_MWh > 0),
  CONSTRAINT constraint_fuelcost_pk PRIMARY KEY (id),
  CONSTRAINT constraint_fuel_fk FOREIGN KEY (fuel_fk)
      REFERENCES fuel (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_modyr_fk FOREIGN KEY (modelling_year_fk)
      REFERENCES modelling_year (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
