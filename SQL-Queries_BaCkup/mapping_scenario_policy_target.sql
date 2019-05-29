CREATE TABLE mapping_scenario_policy_target
(
  id serial NOT NULL,
  scenario_policy_target_fk integer,
  policy_target_value_fk integer,
  CONSTRAINT constraint_mapscpoltarg_pk PRIMARY KEY (id),
  CONSTRAINT constraint_scpoltarg_fk FOREIGN KEY (scenario_policy_target_fk)
      REFERENCES scenario_policy_target (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_poltargval_fk FOREIGN KEY (policy_target_value_fk)
      REFERENCES policy_target_value (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
