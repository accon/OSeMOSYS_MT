CREATE OR REPLACE VIEW view_policy_target_power_plant_type AS 
 SELECT DISTINCT ptt.id AS policy_target_type_id,
    ptt.name AS target_type_name,
    ptt.limit_type AS upper_lower,
    ppt.name AS power_plant_type_name,
    scpt.name AS scenario_policy_target
   FROM policy_target_type ptt
     JOIN mapping_policy_target_power_plant_type m ON ptt.id = m.eligible_for_policy_target_type_fk
     JOIN power_plant_type ppt ON m.power_plant_type_fk = ppt.id
     JOIN policy_target_value ptv ON ptt.id = ptv.policy_target_type_fk
     JOIN mapping_scenario_policy_target m2 ON ptv.id = m2.policy_target_value_fk
     JOIN scenario_policy_target scpt ON m2.scenario_policy_target_fk = scpt.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE scpt.id = mrp.scenario_policy_target_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY ptt.id, ptt.limit_type;