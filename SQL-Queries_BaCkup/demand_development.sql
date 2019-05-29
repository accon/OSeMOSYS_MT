CREATE TABLE demand_development
(
  id serial NOT NULL,
  area_fk integer,
  modelling_year_fk integer,
  demand_type_fk integer,
  demand__MWh_a numeric,
  CONSTRAINT constraint_demanddev_pk PRIMARY KEY (id),
  CONSTRAINT constraint_area_fk FOREIGN KEY (area_fk)
      REFERENCES area (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_modyear_fk FOREIGN KEY (modelling_year_fk)
      REFERENCES modelling_year (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_demand_type_fk FOREIGN KEY (demand_type_fk)
      REFERENCES demand_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,

  CONSTRAINT constraint_demand CHECK (demand__MWh_a > 0::numeric)
)
WITH (
  OIDS=FALSE
);