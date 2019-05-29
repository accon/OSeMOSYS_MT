-- View: view_storage_type_choice

DROP VIEW view_storage_type_choice;

CREATE OR REPLACE VIEW view_storage_type_choice AS 
 SELECT DISTINCT stt.id AS storage_type_id,
    stt.name AS storage_type_name
   FROM storage_type stt
     JOIN storage_cost stc ON stt.id = stc.storage_type_fk
     JOIN mapping_scenario_storage_cost m ON stc.id = m.storage_cost_fk
     JOIN scenario_storage_cost scstc ON m.scenario_storage_cost_fk = scstc.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE scstc.id = mrp.scenario_storage_cost_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY stt.id;