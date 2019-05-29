CREATE TABLE mapping_policy_target_power_plant_type
(
  id serial NOT NULL,
  power_plant_type_fk integer,
  eligible_for_policy_target_type_fk integer,
  CONSTRAINT constraint_mappoltargppt_pk PRIMARY KEY (id),
  CONSTRAINT constraint_ppt_fk FOREIGN KEY (power_plant_type_fk)
      REFERENCES power_plant_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_poltargtyp_fk FOREIGN KEY (eligible_for_policy_target_type_fk)
      REFERENCES policy_target_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);