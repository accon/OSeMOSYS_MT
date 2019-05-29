-- Table: power_plant_type

DROP TABLE power_plant_type;

CREATE TABLE power_plant_type
(
  id serial NOT NULL,
  name text,
  fuel_fk integer,
  fuel_optional_fk integer,
  efficiency_average numeric,
  emission_co2_average__kg_mwh numeric,
  CONSTRAINT constraint_pp_type_pk PRIMARY KEY (id),
  CONSTRAINT constraint_fuel_fk FOREIGN KEY (fuel_fk)
      REFERENCES fuel (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_optional_fuel_fk FOREIGN KEY (fuel_optional_fk)
      REFERENCES fuel (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT power_plant_type_efficiency_average_check CHECK (efficiency_average >= 0::numeric AND efficiency_average <= 1::numeric),
  CONSTRAINT power_plant_type_emission_co2_average__kg_mwh_check CHECK (emission_co2_average__kg_mwh >= 0::numeric)
)
WITH (
  OIDS=FALSE
);
