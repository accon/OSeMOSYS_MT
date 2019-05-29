-- View: view_storage_efficiency

-- DROP VIEW view_storage_efficiency;

CREATE OR REPLACE VIEW view_storage_efficiency AS 
 SELECT stt.id AS storage_type_id,
    stt.name AS storage_type,
    ste.charge_efficiency AS storage_charge_efficiency,
    ste.discharge_efficiency AS storage_discharge_efficiency,
    my.year AS modelling_year,
    ppt.name AS power_plant_type,
    aa.name AS area_aggregated
   FROM storage_type stt
     JOIN storage_efficiency ste ON stt.id = ste.storage_type_fk
     JOIN modelling_year my ON ste.modelling_year_fk = my.id
     JOIN mapping_scenario_efficiency m ON ste.id = m.storage_efficiency_fk
     JOIN scenario_efficiency sce ON m.scenario_efficiency_fk = sce.id
     JOIN mapping_power_plant_type_storage_type m2 ON stt.id = m2.storage_type_fk
     JOIN power_plant_type ppt ON m2.power_plant_type_fk = ppt.id
     JOIN area_aggregated aa ON sce.area_aggregated_fk = aa.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE sce.id = mrp.scenario_efficiency_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY aa.name, stt.id, my.year;
