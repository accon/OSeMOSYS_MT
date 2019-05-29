CREATE TABLE scenario_policy_target
(
  id serial NOT NULL,
  name text,
  area_aggregated_fk integer,
  CONSTRAINT constraint_sctarg_pk PRIMARY KEY (id),
  CONSTRAINT constraint_aa_fk FOREIGN KEY (area_aggregated_fk)
      REFERENCES area_aggregated (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
