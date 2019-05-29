-- View: view_power_plant_costs

DROP VIEW view_power_plant_costs;

CREATE OR REPLACE VIEW view_power_plant_costs AS 
 SELECT ppc.id AS power_plant_cost_id,
    ppc.capital_cost__k_euro_mw,
    ppc.fix_cost__k_euro_mw_a,
    ppc.variable_cost__k_euro_mwh,
    ppt.name AS power_plant_type,
    my.year AS modelling_year,
    aa.name AS area_aggregated
   FROM power_plant_cost ppc
     JOIN power_plant_type ppt ON ppc.power_plant_type_fk = ppt.id
     JOIN mapping_scenario_power_plant_cost m ON m.power_plant_cost_fk = ppc.id
     JOIN scenario_power_plant_cost scppc ON scppc.id = m.scenario_power_plant_cost_fk
     JOIN modelling_year my ON my.id = ppc.modelling_year_fk
     JOIN area_aggregated aa ON m.area_aggregated_fk = aa.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE scppc.id = mrp.scenario_power_plant_cost_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY ppt.id, my.year;
