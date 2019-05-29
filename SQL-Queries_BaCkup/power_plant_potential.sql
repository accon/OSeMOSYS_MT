CREATE TABLE grid_type
(
  id serial NOT NULL,
  voltage_level numeric CHECK (voltage_level > 0),
  voltage_type text CHECK (voltage_type = 'AC' OR voltage_type 'DC'),
  losses_average__MW_km numeric CHECK (losses_average__MW_km > 0),
  CONSTRAINT constraint_grid_type_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
