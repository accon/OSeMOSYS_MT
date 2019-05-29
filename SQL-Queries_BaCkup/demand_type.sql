CREATE TABLE demand_type
(
  id serial NOT NULL,
  name text,
  mean_value__MW numeric CHECK (mean_value__MW > 0::numeric),
  standard_deviation__MW numeric CHECK (standard_deviation__MW > 0::numeric),
  CONSTRAINT constraint_demand_type_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

