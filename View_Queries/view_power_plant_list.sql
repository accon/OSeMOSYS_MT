DROP VIEW view_power_plant_list;

CREATE OR REPLACE VIEW view_power_plant_list AS 
 SELECT ppl.*,
    aa.name AS area_aggregated,
    ppt.name AS power_plant_type,
    f.name AS fuel
   FROM power_plant ppl
     JOIN area a ON ppl.area_fk = a.id
     JOIN mapping_area_aggregated_area m ON a.id = m.area_fk
     JOIN area_aggregated aa ON m.area_aggregated_fk = aa.id
     JOIN power_plant_type ppt ON ppl.power_plant_type_fk = ppt.id
     LEFT JOIN fuel f ON ppl.fuel_fk = f.id
     JOIN mapping_area_scenario m2 ON aa.id = m2.area_aggregated_fk
     JOIN scenario_area sca ON m2.scenario_area_fk = sca.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE sca.id = mrp.scenario_area_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY ppl.id;

--ALTER TABLE view_power_plant_costs
--  OWNER TO postgres;
