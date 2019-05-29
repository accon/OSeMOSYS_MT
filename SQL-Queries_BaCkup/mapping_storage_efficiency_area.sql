-- Table: mapping_power_plant_efficiency_area

-- DROP TABLE mapping_power_plant_efficiency_area;

CREATE TABLE mapping_storage_efficiency_area
(
  id integer NOT NULL DEFAULT nextval('mapping_pp_efficiency_area_id_seq'::regclass),
  storage_efficiency_fk integer,
  area_fk integer,
  CONSTRAINT constraint_mapsteffarea_pk PRIMARY KEY (id),
  CONSTRAINT constraint_area_fk FOREIGN KEY (area_fk)
      REFERENCES area (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_steff_fk FOREIGN KEY (storage_efficiency_fk)
      REFERENCES storage_efficiency (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
