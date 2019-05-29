CREATE TABLE reserve_margin
(
  id integer,
  name text,
  fuel_fk integer,
  area_aggregated_fk integer,
  CONSTRAINT constraint_reservmar_pk PRIMARY KEY (id),
  CONSTRAINT constraint_fuel_fk FOREIGN KEY (fuel_fk)
  REFERENCES fuel (id) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_aa_fk FOREIGN KEY (area_aggregated_fk)
  REFERENCES area_aggregated (id) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
