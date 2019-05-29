-- View: view_power_plant_list

-- DROP VIEW view_power_plant_list;

--CREATE OR REPLACE VIEW view_power_plant_list AS 
 SELECT ppl.id,
    ppl.name,
    ppl.unit_name,
    ppl.owner,
    ppl.owner_type,
    ppl.area_fk,
    ppl.fuel_fk,
    ppl.commissioning_year,
    ppl.lifetime__a,
    ppl.installed_capacity__mw,
    ppl.efficiency,
    ppl.power_plant_type_fk,
    ppl.time_ramping_up__min_mw,
    ppl.time_ramping_down__min_mw,
    ppl.maintenance_time__h_a,
    ppl.min_run_time__h,
    ppl.start_up_costs__euro,
    ppl.secured_capacity__1,
    ppl.notes,
    aa.name AS area_aggregated,
    ppt.name AS power_plant_type,
    f.name AS fuel
   FROM power_plant ppl
     JOIN area a ON ppl.area_fk = a.id
     JOIN mapping_area_aggregated_area m ON a.id = m.area_fk
     JOIN area_aggregated aa ON m.area_aggregated_fk = aa.id
     JOIN power_plant_type ppt ON ppl.power_plant_type_fk = ppt.id
     LEFT JOIN fuel f ON ppl.fuel_fk = f.id
     JOIN mapping_scenario_power_plant_existing m2 ON ppl.id = m2.power_plant_fk
     JOIN scenario_power_plant_existing scppex ON m2.scenario_power_plant_existing_fk = scppex.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE scppex.id = mrp.scenario_power_plant_existing_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY ppl.id;
