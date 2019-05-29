CREATE TABLE capacity_factor_series
(
  id integer,
  name text,
  area_fk integer,
  modelling_year_fk integer,
  CONSTRAINT constraint_cfs_pk PRIMARY KEY (id),
  CONSTRAINT constraint_area_fk FOREIGN KEY (area_fk)
      REFERENCES area (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_modyr_fk FOREIGN KEY (modelling_year_fk)
      REFERENCES modelling_year (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);