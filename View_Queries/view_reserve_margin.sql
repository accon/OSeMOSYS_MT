CREATE OR REPLACE VIEW view_reserve_margin AS 
 SELECT rm.id AS reserve_margin_id,
	f.name AS fuel_name,
    rmv.reserve_margin AS reserve_margin_value,
    my.year AS modelling_year,
    scrm.name AS scenario_reserve_margin_name,
    aa.name AS area_aggregated
   FROM reserve_margin rm
     JOIN fuel f ON rm.fuel_fk = f.id 
     JOIN mapping_reserve_margin_value m ON rm.id = m.reserve_margin_fk
     JOIN reserve_margin_value rmv ON m.reserve_margin_value_fk = rmv.id
     JOIN mapping_scenario_reserve_margin m2 ON rm.id = m2.reserve_margin_fk
     JOIN scenario_reserve_margin scrm ON m2.scenario_reserve_margin_fk = scrm.id
     JOIN modelling_year my ON rmv.modelling_year_fk = my.id
     JOIN area_aggregated aa ON rm.area_aggregated_fk = aa.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE scrm.id = mrp.scenario_reserve_margin_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY f.name, my.year;