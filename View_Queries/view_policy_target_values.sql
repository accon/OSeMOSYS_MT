-- View: view_policy_target_values

DROP VIEW view_policy_target_values;

CREATE OR REPLACE VIEW view_policy_target_values AS 
 SELECT DISTINCT ptv.id AS policy_target_value_id,
    ptt.name AS target_type_name,
    ptt.limit_type AS upper_lower,
    ptt.reference_type AS target_reference_type,
    f.name AS fuel_name,
    aa.name AS area_aggregated_name,
    my.year AS modelling_year,
    scpt.name AS scenario_policy_target,
    ptv.target_value,
    ptv.target_unit
   FROM policy_target_value ptv
     JOIN policy_target_type ptt ON ptt.id = ptv.policy_target_type_fk
     JOIN mapping_policy_target_power_plant_type m ON ptt.id = m.eligible_for_policy_target_type_fk
     JOIN mapping_policy_target_fuel m2 ON ptt.id = m2.policy_target_type_fk
     JOIN fuel f ON m2.fuel_fk = f.id
     JOIN mapping_scenario_policy_target m3 ON ptv.id = m3.policy_target_value_fk
     JOIN scenario_policy_target scpt ON m3.scenario_policy_target_fk = scpt.id
     JOIN area_aggregated aa ON scpt.area_aggregated_fk = aa.id
     JOIN modelling_year my ON ptv.modelling_year_fk = my.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE scpt.id = mrp.scenario_policy_target_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY ptv.id, ptt.limit_type, my.year;