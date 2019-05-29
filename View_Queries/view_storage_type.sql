CREATE OR REPLACE VIEW view_storage_type AS 
 SELECT DISTINCT stt.name AS storage_type_name,
    stt.lifetime__a AS storage_lifetime__a,
    stt.max_charge_rate_average__mw,
    stt.max_discharge_rate_average__mw,
    stt.min_storage_charge,
    ppt1.name AS power_plant_type_charge,
    ppt2.name AS power_plant_type_discharge
   FROM storage_type stt
     JOIN power_plant_type ppt1 ON stt.power_plant_type_fk_charge = ppt1.id 
     JOIN power_plant_type ppt2 ON stt.power_plant_type_fk_discharge = ppt2.id
     JOIN storage_cost stc ON stt.id = stc.storage_type_fk
     JOIN mapping_scenario_storage_cost m2 ON stc.id = m2.storage_cost_fk
     JOIN scenario_storage_cost scstc ON m2.scenario_storage_cost_fk = scstc.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE scstc.id = mrp.scenario_storage_cost_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY stt.name;