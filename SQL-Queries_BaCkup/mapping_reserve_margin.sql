CREATE TABLE mapping_reserve_margin_value
(
  id serial NOT NULL,
  reserve_margin_fk integer,
  reserve_margin_value_fk integer,
  CONSTRAINT constraint_mapreservemar_pk PRIMARY KEY (id),
  CONSTRAINT constraint_reservmar_fk FOREIGN KEY (reserve_margin_fk)
      REFERENCES reserve_margin (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_reservmarval_fk FOREIGN KEY (reserve_margin_value_fk)
      REFERENCES reserve_margin_value (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);