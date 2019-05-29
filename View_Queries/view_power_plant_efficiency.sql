-- View: view_power_plant_efficiency

-- DROP VIEW view_power_plant_efficiency;

CREATE OR REPLACE VIEW view_power_plant_efficiency AS 
 SELECT ppt.id AS pp_type_id,
    ppt.name AS pp_type,
    ppe.efficiency AS pp_efficiency,
    my.year AS modelling_year,
    f.name AS fuel
   FROM power_plant_type ppt
     JOIN power_plant_efficiency ppe ON ppt.id = ppe.power_plant_type_fk
     JOIN modelling_year my ON ppe.modelling_year_fk = my.id
     JOIN mapping_scenario_efficiency m ON ppe.id = m.power_plant_efficiency_fk
     JOIN scenario_efficiency sce ON m.scenario_efficiency_fk = sce.id
     LEFT JOIN fuel f ON ppt.fuel_fk = f.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE sce.id = mrp.scenario_efficiency_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY ppt.id, my.year;
