CREATE OR REPLACE VIEW view_regions_choice AS 
 SELECT DISTINCT 
			aa.id AS aggregated_area_id,
			aa.name AS aggregated_area_name,
			sa.name AS area_scenario_name,
			mas.granularity_addition

    FROM area_aggregated aa
     JOIN mapping_area_aggregated_area maa ON aa.id = maa.area_aggregated_fk
     JOIN area a ON maa.area_fk = a.id
     JOIN mapping_area_scenario mas ON aa.id = mas.area_aggregated_fk
     JOIN scenario_area sa ON mas.scenario_area_fk = sa.id,
     	modelling_run_properties mrp,
	choice_modelling_run_properties cmrp
	
  WHERE sa.id = mrp.scenario_area_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY aa.id;