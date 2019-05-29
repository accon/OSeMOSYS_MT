CREATE TABLE mapping_policy_target_base_year
(
  id serial NOT NULL,
  policy_target_value_fk integer,
  modelling_year_fk integer,
  CONSTRAINT constraint_mappoltargbasyr_pk PRIMARY KEY (id),
  CONSTRAINT constraint_poltargval_fk FOREIGN KEY (policy_target_value_fk)
      REFERENCES policy_target_value (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_modyr_fk FOREIGN KEY (modelling_year_fk)
      REFERENCES modelling_year (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);