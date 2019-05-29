CREATE OR REPLACE VIEW view_storage_costs AS 
 SELECT stc.id AS storage_cost_id,
	stc.capital_cost__euro_mw,
	stc.fix_cost__euro_mw,
	stc.variable_cost__euro_mwh,
	stt.name AS storage_type,
    my.year AS modelling_year,
    aa.name AS aggregated_area_name
   FROM storage_cost stc
     JOIN storage_type stt ON stc.storage_type_fk = stt.id
     JOIN mapping_storage_cost_scenario m ON m.storage_cost_fk = stc.id
     JOIN scenario_storage_cost scstc ON scstc.id = m.scenario_storage_cost_fk
     JOIN modelling_year my ON my.id = stc.modelling_year_fk
     JOIN area_aggregated aa ON scstc.area_aggregated_fk = aa.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE scstc.id = mrp.scenario_power_plant_cost_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY stt.id, my.year;
