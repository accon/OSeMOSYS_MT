-- Table: policy_target_value

DROP TABLE policy_target_value;

CREATE TABLE policy_target_value
(
  id serial NOT NULL,
  policy_target_type_fk integer,
  modelling_year_fk integer,
  target_value numeric,
  target_unit text,
  CONSTRAINT constraint_poltargval_pk PRIMARY KEY (id),
  CONSTRAINT policy_target_value_value_check CHECK (target_value > 0::numeric),
  CONSTRAINT constraint_poltargtype_fk FOREIGN KEY (id)
      REFERENCES policy_target_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_modyr_fk FOREIGN KEY (id)
      REFERENCES modelling_year (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);