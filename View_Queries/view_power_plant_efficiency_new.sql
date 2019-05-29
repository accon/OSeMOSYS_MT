-- View: view_power_plant_efficiency

-- DROP VIEW view_power_plant_efficiency;

CREATE OR REPLACE VIEW view_power_plant_efficiency AS 
 SELECT ppt.id AS pp_type_id,
    ppt.name AS pp_type,
    ppe.efficiency AS pp_efficiency,
    my.year AS modelling_year,
    f.name AS fuel,
    aa.name AS area_aggregated
   FROM power_plant_type ppt
     JOIN power_plant_efficiency ppe ON ppt.id = ppe.power_plant_type_fk
     JOIN modelling_year my ON ppe.modelling_year_fk = my.id
     JOIN mapping_scenario_efficiency m ON ppe.id = m.power_plant_efficiency_fk
     JOIN scenario_efficiency sce ON m.scenario_efficiency_fk = sce.id
     LEFT JOIN fuel f ON ppt.fuel_fk = f.id
     JOIN mapping_power_plant_efficiency_area m2 ON ppe.id = m2.power_plant_efficiency_fk
     JOIN area a ON m2.area_fk = a.id
     JOIN mapping_area_aggregated_area m3 ON a.id = m3.area_fk
     JOIN area_aggregated aa ON m3.area_aggregated_fk = aa.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE sce.id = mrp.scenario_efficiency_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY aa.name, ppt.id, my.year;

ALTER TABLE view_power_plant_efficiency
  OWNER TO postgres;
