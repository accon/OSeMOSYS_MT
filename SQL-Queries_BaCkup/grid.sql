CREATE TABLE grid
(
  id serial NOT NULL,
  area_1_fk integer,
  area_2_fk integer,
  grid_type_fk integer,
  losses_specific__MW_km numeric CHECK (losses_specific__MW_km > 0),
  CONSTRAINT constraint_grid_pk PRIMARY KEY (id),
  CONSTRAINT constraint_area1_fk FOREIGN KEY (area_1_fk)
	REFERENCES area (id) MATCH SIMPLE 
	ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_area2_fk FOREIGN KEY (area_2_fk)
	REFERENCES area (id) MATCH SIMPLE 
	ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_grid_type_fk FOREIGN KEY (grid_type_fk)
	REFERENCES grid_type (id) MATCH SIMPLE 
	ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
