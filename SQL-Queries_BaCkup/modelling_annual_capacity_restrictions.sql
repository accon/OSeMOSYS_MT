CREATE TABLE modelling_annual_capacity_restrictions
(
  id serial NOT NULL,
  power_plant_type_fk integer,
  modelling_year_fk integer,
  area_aggregated_fk integer,
  capacity__MW numeric,
  min_max text,
  CONSTRAINT constraint_modanncaprest_pk PRIMARY KEY (id),
  CONSTRAINT constraint_pptype_fk FOREIGN KEY (power_plant_type_fk)
      REFERENCES power_plant_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_modyr_fk FOREIGN KEY (modelling_year_fk)
      REFERENCES modelling_year (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_aagg_fk FOREIGN KEY (area_aggregated_fk)
      REFERENCES area_aggregated (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);