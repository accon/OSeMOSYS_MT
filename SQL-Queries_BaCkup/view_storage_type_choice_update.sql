-- View: view_storage_type_choice

DROP VIEW view_storage_type_choice;

CREATE OR REPLACE VIEW view_storage_type_choice AS 
 SELECT DISTINCT stt.id AS storage_type_id,
    stt.name AS storage_type_name,
    ppt.name AS power_plant_type
   FROM storage_type stt
     JOIN storage_cost stc ON stt.id = stc.storage_type_fk
     JOIN mapping_storage_cost_scenario m ON stc.id = m.storage_cost_fk
     JOIN scenario_storage_cost scstc ON m.scenario_storage_cost_fk = scstc.id
     JOIN mapping_power_plant_type_storage_type m2 ON m2.storage_type_fk = stt.id
     JOIN power_plant_type ppt ON m2.power_plant_type_fk = ppt.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE scstc.id = mrp.scenario_storage_cost_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY stt.id;
