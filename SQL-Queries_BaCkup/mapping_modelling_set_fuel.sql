CREATE TABLE mapping_modelling_set_fuel
(
  id serial NOT NULL,
  modelling_set_fuel_fk integer,
  fuel_fk integer,
  CONSTRAINT constraint_map_mod_set_fuel_pk PRIMARY KEY (id),
  CONSTRAINT constraint_mod_set_fuel_fk FOREIGN KEY (modelling_set_fuel_fk)
      REFERENCES modelling_set_fuel (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_fuel_fk FOREIGN KEY (fuel_fk)
      REFERENCES fuel (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);

