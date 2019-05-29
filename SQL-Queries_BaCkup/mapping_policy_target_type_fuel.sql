CREATE TABLE mapping_policy_target_fuel
(
  id serial NOT NULL,
  fuel_fk integer,
  policy_target_type_fk integer,
  CONSTRAINT constraint_mappoltargfuel_pk PRIMARY KEY (id),
  CONSTRAINT constraint_fuel_fk FOREIGN KEY (fuel_fk)
      REFERENCES fuel (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_poltargtyp_fk FOREIGN KEY (policy_target_type_fk)
      REFERENCES policy_target_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);