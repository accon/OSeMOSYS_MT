CREATE TABLE mapping_power_plant_storage
(
  id serial NOT NULL,
  power_plant_fk integer,
  storage_fk integer,
  CONSTRAINT constraint_mapppst_pk PRIMARY KEY (id),
  CONSTRAINT constraint_pp_fk FOREIGN KEY (power_plant_fk)
      REFERENCES power_plant (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_st_fk FOREIGN KEY (storage_fk)
      REFERENCES storage (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);