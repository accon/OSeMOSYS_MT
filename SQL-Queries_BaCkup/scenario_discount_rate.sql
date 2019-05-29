-- Table: scenario_demand

-- DROP TABLE scenario_demand;

CREATE TABLE scenario_discount_rate
(
  id serial NOT NULL,
  name text,
  CONSTRAINT constraint_scdiscrate_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE scenario_discount_rate
  OWNER TO postgres;
