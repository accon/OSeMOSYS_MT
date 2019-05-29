CREATE TABLE storage_cost
(
  id serial NOT NULL,
  storage_type_fk integer,
  modelling_year_fk integer,
  capital_cost__euro_MW numeric,
  capital_cost__euro_MWh numeric,
  fix_cost__euro_MW numeric,
  fix_cost__euro_MWh numeric,
  variable_cost__euro_MW numeric,
  variable_cost__euro_MWh numeric,
  CONSTRAINT constraint_storcost_pk PRIMARY KEY (id),
  CONSTRAINT constraint_stortype_fk FOREIGN KEY (storage_type_fk)
      REFERENCES storage_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_modyr_fk FOREIGN KEY (modelling_year_fk)
      REFERENCES modelling_year (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
