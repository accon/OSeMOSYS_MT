-- View: view_series_capacity_factors

-- DROP VIEW view_series_capacity_factors;

CREATE OR REPLACE VIEW view_series_capacity_factors AS 
 SELECT DISTINCT scfv.id AS series_capacity_factor_id,
    scfv.timestep_fk,
    ts.unixtime,
    ts.timestamp_w_tz,
    my.year AS modelling_year,
    scfv.available_capacity,
    ppt.name AS power_plant_type,
    a.name AS area,
    aa.name AS area_aggregated
   FROM series_capacity_factor_value scfv
     JOIN power_plant_type ppt ON scfv.power_plant_type_fk = ppt.id
     JOIN area a ON scfv.area_fk = a.id
     JOIN mapping_area_aggregated_area maa ON a.id = maa.area_fk
     JOIN area_aggregated aa ON maa.area_aggregated_fk = aa.id
     JOIN power_plant_cost ppc ON ppt.id = ppc.power_plant_type_fk
     JOIN mapping_power_plant_cost_scenario m ON ppc.id = m.power_plant_cost_fk
     JOIN scenario_power_plant_cost scppc ON m.scenario_power_plant_cost_fk = scppc.id
     JOIN timestep ts ON scfv.timestep_fk = ts.id
     JOIN mapping_series_capacity_factor m2 ON scfv.id = m2.series_capacity_factor_value_fk
     JOIN series_capacity_factor scf ON m2.series_capacity_factor_fk = scf.id
     JOIN modelling_year my ON scf.modelling_year_fk = my.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE scppc.id = mrp.scenario_power_plant_cost_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY ppt.name, my.year, scfv.id;
