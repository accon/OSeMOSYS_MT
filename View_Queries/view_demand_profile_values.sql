﻿--CREATE OR REPLACE VIEW view_demand_profiles AS 
 SELECT dp.id AS demand_profile_id,
	dp.annual_demand__mwh,
	a.name
	my.year AS modelling_year 
   FROM demand_profile dp
	JOIN area a ON dp.area_fk = a.id
	JOIN mapping_modelling_year_demand_profile m2 ON dp.id = m2.demand_profile_fk
	JOIN modelling_year my ON m2.modelling_year_fk = my.id
	JOIN mapping_scenario_demand_map_modelling_year_demand_profile m3 ON m2.id = m3.mapping_modelling_year_demand_profile_fk,
	modelling_run_properties mrp,
	choice_modelling_run_properties cmrp
WHERE m3.scenario_demand_fk = mrp.scenario_demand_fk AND mrp.id = cmrp.modelling_run_properties_fk
ORDER BY my.year, dp.id;