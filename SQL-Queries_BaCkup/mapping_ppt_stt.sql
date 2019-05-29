-- Table: mapping_power_plant_storage

DROP TABLE mapping_power_plant_storage;

CREATE TABLE mapping_power_plant_type_storage_type
(
  id serial NOT NULL,
  power_plant_type_fk integer,
  storage_type_fk integer,
  CONSTRAINT constraint_map_ppt_stt_pk PRIMARY KEY (id),
  CONSTRAINT constraint_ppt_fk FOREIGN KEY (power_plant_type_fk)
      REFERENCES power_plant_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_stt_fk FOREIGN KEY (storage_type_fk)
      REFERENCES storage_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
