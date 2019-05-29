-- Table: reserve_margin_value

DROP TABLE reserve_margin_value;

CREATE TABLE reserve_margin_value
(
  id integer NOT NULL,
  reserve_margin numeric,
  modelling_year_fk integer,
  CONSTRAINT constraint_reservmarval_pk PRIMARY KEY (id),
  CONSTRAINT constraint_modyr_fk FOREIGN KEY (modelling_year_fk)
  REFERENCES modelling_year (id) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
