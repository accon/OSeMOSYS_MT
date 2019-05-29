CREATE TABLE power_plant_cost
(
  id serial NOT NULL,
  power_plant_type_fk integer,
  modelling_year_fk integer,
  capital_cost__euro_MW numeric,
  fix_cost__euro_MW numeric,
  variable_cost__euro_MWh numeric,
  CONSTRAINT constraint_ppcost_pk PRIMARY KEY (id),
  CONSTRAINT constraint_pptype_fk FOREIGN KEY (power_plant_type_fk)
      REFERENCES power_plant_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
