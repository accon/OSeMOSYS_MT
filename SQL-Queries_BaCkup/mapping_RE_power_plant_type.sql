CREATE TABLE mapping_RE_power_plant_type
(
  id serial NOT NULL,
  power_plant_type_fk integer,
  is_RE boolean,
  CONSTRAINT constraint_map_RE_ppt_pk PRIMARY KEY (id),
  CONSTRAINT constraint_ppt_fk FOREIGN KEY (power_plant_type_fk)
      REFERENCES power_plant_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);