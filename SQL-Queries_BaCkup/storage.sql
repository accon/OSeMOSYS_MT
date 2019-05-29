-- Table: storage

DROP TABLE storage;

CREATE TABLE storage
(
  id serial NOT NULL,
  name text,
  power__mw numeric,
  capacity__mwh numeric,
  storage_type_fk integer,
  efficiency_charge numeric,
  efficiency_discharge numeric,
  commissioning_year numeric,
  degradation_rate__percent_a numeric,
  capacity_to_max_power_average__h numeric,
  min_charge_level__mwh numeric,
  CONSTRAINT constraint_storage_pk PRIMARY KEY (id),
  CONSTRAINT constraint_storage_type_fk FOREIGN KEY (storage_type_fk)
      REFERENCES storage_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT storage_capacity__mwh_check CHECK (capacity__mwh >= 0::numeric),
  CONSTRAINT storage_capacity_to_max_power_average__h_check CHECK (capacity_to_max_power_average__h >= 0::numeric),
  CONSTRAINT storage_commissioning_year_check CHECK (commissioning_year >= 1850::numeric),
  CONSTRAINT storage_degradation_rate__percent_a_check CHECK (degradation_rate__percent_a >= 0::numeric AND degradation_rate__percent_a <= 1::numeric),
  CONSTRAINT storage_efficiency_charge_check CHECK (efficiency_charge >= 0::numeric AND efficiency_charge <= 1::numeric),
  CONSTRAINT storage_efficiency_discharge_check CHECK (efficiency_discharge >= 0::numeric AND efficiency_discharge <= 1::numeric),
  CONSTRAINT storage_min_charge_level__mwh_check CHECK (min_charge_level__mwh >= 0::numeric),
  CONSTRAINT storage_power__mw_check CHECK (power__mw >= 0::numeric)
)
WITH (
  OIDS=FALSE
);
