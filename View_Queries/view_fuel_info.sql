
--CREATE OR REPLACE VIEW view_power_plant_info AS 
 SELECT DISTINCT f.id AS fuel_id,
    f.name AS fuel_name
--    scppc.name AS pp_cost_scenario_name
   FROM fuel f
     JOIN mapping_modelling_set_fuel m ON f.id = m.fuel_fk
     JOIN modelling_set_fuel msf ON m.modelling_set_fuel_fk = msf.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE msf.id = mrp.modelling_set_fuel_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY f.id;