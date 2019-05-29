CREATE TABLE mapping_series_capacity_factor
(
  id serial NOT NULL,
  series_capacity_factor_fk integer,
  series_capacity_factor_value_fk integer,
  CONSTRAINT constraint_mapscf_pk PRIMARY KEY (id),
  CONSTRAINT constraint_scf_fk FOREIGN KEY (series_capacity_factor_fk)
      REFERENCES series_capacity_factor (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_scfval_fk FOREIGN KEY (series_capacity_factor_value_fk)
      REFERENCES series_capacity_factor_value (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);