-- View: emissions

DROP VIEW emissions;

CREATE OR REPLACE VIEW emissions AS 
 SELECT e.id AS emission_id,
	e.name AS emission_name,
	mse.name AS modelling_set_emission_name
	
   FROM emission e
     JOIN mapping_modelling_set_emission m ON e.id = m.emission_fk
     JOIN modelling_set_emission mse ON m.modelling_set_emission_fk = mse.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
    
  WHERE mse.id = mrp.modelling_set_emission_fk AND mrp.id = cmrp.modelling_run_properties_fk;
