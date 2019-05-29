CREATE TABLE reserve_margin_value
(
  id integer,
  reserve_margin numeric,
  CONSTRAINT constraint_reservmarval_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
