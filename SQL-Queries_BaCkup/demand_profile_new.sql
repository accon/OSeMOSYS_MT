-- Table: demand_profile

CREATE TABLE demand_profile
(
  id serial NOT NULL,
  modelling_year_fk integer,
  area_fk integer,
  demand_type_fk integer,
  annual_demand__MWh numeric,
  CONSTRAINT constraint_demprof_pk PRIMARY KEY (id),
  CONSTRAINT constraint_modyr_fk FOREIGN KEY (modelling_year_fk)
      REFERENCES modelling_year (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_area_fk FOREIGN KEY (area_fk)
      REFERENCES area (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_demtype_fk FOREIGN KEY (demand_type_fk)
      REFERENCES demand_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT annual_demand_check CHECK (annual_demand__MWh >= 0::numeric)
)
WITH (
  OIDS=FALSE
);
