CREATE TABLE fuel
(
  id serial NOT NULL,
  name text,
  specific_costs__euro_MWh numeric CHECK (specific_costs__euro_MWh > 0),
  specific_emission_CO2__kg_MWh numeric CHECK (specific_emission_CO2__kg_MWh > 0),
  CONSTRAINT constraint_fuel_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

