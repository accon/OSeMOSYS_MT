CREATE OR REPLACE VIEW view_modelling_capacity_restrictions AS 
 SELECT macr.id,
    macr.capacity__mw,
    macr.min_max,
    ppt.name AS power_plant_type,
    my.year AS modelling_year,
    aa.name AS area_aggregated
   FROM modelling_annual_capacity_restrictions macr
     JOIN power_plant_type ppt ON macr.power_plant_type_fk = ppt.id
     JOIN modelling_year my ON macr.modelling_year_fk = my.id
     JOIN area_aggregated aa ON macr.area_aggregated_fk = aa.id
     JOIN mapping_scenario_capacity_restrictions m ON macr.id = m.modelling_annual_capacity_restrictions_fk
     JOIN scenario_capacity_restrictions sccr ON m.scenario_capacity_restrictions_fk = sccr.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE sccr.id = mrp.scenario_capacity_restrictions_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY macr.id, ppt.name, macr.min_max, my.year, aa.name;
