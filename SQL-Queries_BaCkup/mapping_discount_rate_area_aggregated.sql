CREATE TABLE mapping_discount_rate_area_aggregated
(
  id serial NOT NULL,
  discount_rate_fk integer,
  area_aggregated_fk integer,
  CONSTRAINT constraint_mapdrateaa_pk PRIMARY KEY (id),
  CONSTRAINT constraint_discrate_fk FOREIGN KEY (discount_rate_fk)
      REFERENCES discount_rate (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_aa_fk FOREIGN KEY (area_aggregated_fk)
      REFERENCES area_aggregated (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);