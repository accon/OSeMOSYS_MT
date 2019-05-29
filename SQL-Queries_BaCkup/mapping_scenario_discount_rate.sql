CREATE TABLE mapping_scenario_discount_rate
(
  id serial NOT NULL,
  scenario_discount_rate_fk integer,
  discount_rate_fk integer,
  CONSTRAINT constraint_mapscdiscrate_pk PRIMARY KEY (id),
  CONSTRAINT constraint_scdiscrate_fk FOREIGN KEY (scenario_discount_rate_fk)
      REFERENCES scenario_discount_rate (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_discrate_fk FOREIGN KEY (discount_rate_fk)
      REFERENCES discount_rate (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
