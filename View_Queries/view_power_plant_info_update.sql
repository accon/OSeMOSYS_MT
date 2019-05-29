-- View: view_power_plant_info

-- DROP VIEW view_power_plant_info;

CREATE OR REPLACE VIEW view_power_plant_info AS 
 SELECT DISTINCT ppt.id AS pp_type_id,
    ppt.name AS pp_type_name,
    scppc.name AS pp_cost_scenario_name
   FROM power_plant_type ppt
     JOIN power_plant_cost ppc ON ppt.id = ppc.power_plant_type_fk
     JOIN mapping_scenario_power_plant_cost m ON ppc.id = m.power_plant_cost_fk
     JOIN scenario_power_plant_cost scppc ON m.scenario_power_plant_cost_fk = scppc.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE scppc.id = mrp.scenario_power_plant_cost_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY ppt.id;

COMMENT ON VIEW view_power_plant_info
  IS 'Maybe ammend this view to extract more additional information
';
