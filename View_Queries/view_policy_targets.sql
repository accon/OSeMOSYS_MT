CREATE OR REPLACE VIEW view_policy_targets AS 
 SELECT ptv.id AS policy_target_value_id,
	ptv.target_value,
	ptv.target_unit,
	ppt.name AS power_plant_type,
	ptt.name AS policy_target_type,
	ptt.limit_type AS lower_upper_limit,
    aa.name AS area_aggregated,
    my.year AS modelling_year
   FROM policy_target_value ptv
     JOIN power_plant_type ppt ON ptv.power_plant_type_fk = ppt.id
     JOIN modelling_year my ON ptv.modelling_year_fk = my.id
     JOIN policy_target_type ptt ON ptv.policy_target_type_fk = ptt.id
     JOIN mapping_scenario_policy_target m ON ptv.id = m.policy_target_value_fk
     JOIN scenario_policy_target scpt ON m.scenario_policy_target_fk = scpt.id
     JOIN area_aggregated aa ON scpt.area_aggregated_fk = aa.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE scpt.id = mrp.scenario_policy_target_fk AND mrp.id = cmrp.modelling_run_properties_fk
 ORDER BY ptv.id, my.year;