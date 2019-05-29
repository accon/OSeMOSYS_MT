-- Table: mapping_policy_target

DROP TABLE mapping_policy_target;

CREATE TABLE mapping_policy_target
(
  id serial NOT NULL,
  policy_target_value_fk integer,
  policy_target_set_fk integer,
  policy_target_type_fk integer,
  CONSTRAINT constraint_mappoltarg_pk PRIMARY KEY (id),
  CONSTRAINT constraint_poltargset_fk FOREIGN KEY (policy_target_set_fk)
      REFERENCES policy_target_set (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_poltargtype_fk FOREIGN KEY (policy_target_type_fk)
      REFERENCES policy_target_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_poltargval_fk FOREIGN KEY (policy_target_value_fk)
      REFERENCES policy_target_value (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);

