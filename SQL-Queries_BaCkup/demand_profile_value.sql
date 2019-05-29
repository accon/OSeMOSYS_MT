-- Table: demand_profile_values

DROP TABLE demand_profile_values;

CREATE TABLE demand_profile_value
(
  id serial NOT NULL,
  timestep_fk integer,
  demand_normalized numeric,
  CONSTRAINT constraint_demand_prof_pk PRIMARY KEY (id),
  CONSTRAINT constraint_timestep_fk FOREIGN KEY (timestep_fk)
      REFERENCES timestep (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT demand_profile_demand_normalized_check CHECK (demand_normalized >= 0::numeric AND demand_normalized <= 1::numeric)
)
WITH (
  OIDS=FALSE
);
