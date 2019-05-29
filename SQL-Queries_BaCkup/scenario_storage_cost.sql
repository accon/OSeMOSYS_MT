CREATE TABLE scenario_storage_cost
(
  id serial NOT NULL,
  name text,
  area_aggregated_fk integer,
  CONSTRAINT constraint_scenstorcost_pk PRIMARY KEY (id),
  CONSTRAINT constraint_areaagg_fk FOREIGN KEY (area_aggregated_fk)
      REFERENCES area_aggregated (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
