CREATE OR REPLACE VIEW view_RE_power_plant_types AS 
 SELECT DISTINCT ppt.id AS power_plant_type_id,
    ppt.name AS power_plant_type
   FROM power_plant_type ppt
	JOIN mapping_re_power_plant_type m ON m.power_plant_type_fk = ppt.id
	JOIN power_plant_cost ppc ON ppc.power_plant_type_fk = ppt.id
	JOIN mapping_scenario_power_plant_cost m2 ON m2.power_plant_cost_fk = ppc.id
	JOIN scenario_power_plant_cost scppc ON scppc.id = m2.scenario_power_plant_cost_fk,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE scppc.id = mrp.scenario_power_plant_cost_fk AND mrp.id = cmrp.modelling_run_properties_fk AND m.is_re = TRUE
  ORDER BY ppt.id;