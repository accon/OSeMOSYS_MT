-- Table: policy_target_type

DROP TABLE policy_target_type;

CREATE TABLE policy_target_type
(
  id serial NOT NULL,
  name text,
  limit_type text,
  CONSTRAINT constraint_poltargtype_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
COMMENT ON TABLE policy_target_type
  IS 'For now only absolute targets can be set and only in regard to the target_types defined in policy_target_type';
