CREATE TABLE discount_rate
(
  id serial NOT NULL,
  discount_rate numeric,
  CONSTRAINT constraint_discrate_pk PRIMARY KEY (id)
);

COMMENT ON TABLE discount_rate
  IS 'Discount rates have to be given in values between 0 and 1';
