CREATE OR REPLACE VIEW view_power_plant_emission AS 
 SELECT ppt.id AS pp_type_id,
    ppt.name AS pp_type,
    ppe.emission_factor__tco2e_mwh,
    my.year AS modelling_year,
    aa.name AS aggregated_area
   FROM power_plant_type ppt
     JOIN power_plant_emission ppe ON ppt.id = ppe.power_plant_type_fk
     JOIN modelling_year my ON ppe.modelling_year_fk = my.id
     JOIN mapping_scenario_emission m ON ppe.id = m.power_plant_emission_fk
     JOIN scenario_emission sce ON m.scenario_emission_fk = sce.id
     JOIN area_aggregated aa ON sce.area_aggregated_fk = aa.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE sce.id = mrp.scenario_efficiency_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY ppt.id, my.year;
