CREATE OR REPLACE VIEW view_discount_rate AS 
 SELECT dr.id,
	dr.discount_rate,
	aa.name AS area_aggregated,
	sca.name AS scenario_area_name
   FROM discount_rate dr
     JOIN mapping_discount_rate_area_aggregated m ON m.discount_rate_fk = dr.id
     JOIN area_aggregated aa ON m.area_aggregated_fk = aa.id
     JOIN mapping_area_scenario m2 ON aa.id = m2.area_aggregated_fk
     JOIN scenario_area sca ON m2.scenario_area_fk = sca.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
 WHERE sca.id = mrp.scenario_area_fk AND mrp.id = cmrp.modelling_run_properties_fk;