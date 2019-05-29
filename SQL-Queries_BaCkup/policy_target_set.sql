CREATE TABLE policy_target_set
(
  id serial NOT NULL,
  name text,
  policy_target_type_fk integer,
  CONSTRAINT constraint_poltargset_pk PRIMARY KEY (id),
  CONSTRAINT constraint_poltargtype_fk FOREIGN KEY (id)
	REFERENCES policy_target_type (id) MATCH SIMPLE
	ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
