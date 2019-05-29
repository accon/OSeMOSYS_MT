CREATE TABLE storage_type
(
  id serial NOT NULL,
  name text,
  capacity_to_max_power_average__h numeric CHECK (capacity_to_max_power_average__h > 0),
  capacity_average__MWh numeric CHECK (capacity_average__MWh > 0),
  max_charge_rate_average__MW numeric CHECK (max_charge_rate_average__MW > 0), 
  max_discharge_rate_average__MW numeric CHECK (max_discharge_rate_average__MW > 0), 
  CONSTRAINT constraint_storage_type_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);