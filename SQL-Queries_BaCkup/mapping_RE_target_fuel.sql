CREATE TABLE mapping_RE_target_fuel
(
  id serial NOT NULL,
  fuel_fk integer,
  needs_RE boolean,
  CONSTRAINT constraint_map_RE_target_fuel_pk PRIMARY KEY (id),
  CONSTRAINT constraint_fuel_fk FOREIGN KEY (fuel_fk)
      REFERENCES fuel (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);