CREATE TABLE set_hourly_time_block
(
  id serial NOT NULL,
  name text,
  CONSTRAINT constraint_set_htb_pk PRIMARY KEY (id)  
)
WITH (
  OIDS=FALSE
);

CREATE TABLE mapping_set_hourly_time_blocks_htb
(
  id serial NOT NULL,
  set_hourly_time_block_fk integer,
  hourly_time_block_fk integer,
  CONSTRAINT constraint_map_set_htb_htb_pk PRIMARY KEY (id),
  CONSTRAINT constraint_set_htb_fk FOREIGN KEY (set_hourly_time_block_fk)
      REFERENCES set_hourly_time_block (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT constraint_htb_fk FOREIGN KEY (hourly_time_block_fk)
      REFERENCES hourly_time_block (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
