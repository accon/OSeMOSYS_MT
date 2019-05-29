-- View: view_storage_efficiency

DROP VIEW view_storage_efficiency;

CREATE OR REPLACE VIEW view_storage_efficiency AS 
 SELECT stt.id AS storage_type_id,
    stt.name AS storage_type,
    ste.charge_efficiency AS storage_charge_efficiency,
    ste.discharge_efficiency AS storage_discharge_efficiency,
    my.year AS modelling_year,
    ppt1.name AS power_plant_type_charge,
    ppt2.name AS power_plant_type_discharge,
    aa.name AS area_aggregated
   FROM storage_type stt
     JOIN storage_efficiency ste ON stt.id = ste.storage_type_fk
     JOIN modelling_year my ON ste.modelling_year_fk = my.id
     JOIN mapping_scenario_efficiency m ON ste.id = m.storage_efficiency_fk
     JOIN scenario_efficiency sce ON m.scenario_efficiency_fk = sce.id
     JOIN power_plant_type ppt1 ON stt.power_plant_type_fk_charge = ppt1.id
     JOIN power_plant_type ppt2 ON stt.power_plant_type_fk_discharge = ppt2.id
     JOIN area_aggregated aa ON sce.area_aggregated_fk = aa.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE sce.id = mrp.scenario_efficiency_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY aa.name, stt.id, my.year;
