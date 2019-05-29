-- View: view_demand_profile_values

-- DROP VIEW view_demand_profile_values;

CREATE OR REPLACE VIEW view_demand_profile_values AS 
 SELECT dpv.id,
    dpv.timestep_fk,
    dpv.demand_normalized,
    my.year AS modelling_year,
    aa.name AS aggregated_area
   FROM demand_profile_value dpv
     JOIN mapping_demand_profile_value m ON dpv.id = m.demand_profile_value_fk
     JOIN demand_profile dp ON m.demand_profile_fk = dp.id
     JOIN mapping_modelling_year_demand_profile m2 ON dp.id = m2.demand_profile_fk
     JOIN modelling_year my ON m2.modelling_year_fk = my.id
     JOIN mapping_scenario_demand_map_modelling_year_demand_profile m3 ON m2.id = m3.mapping_modelling_year_demand_profile_fk
     JOIN mapping_area_aggregated_area m4 ON dp.area_fk = m4.area_fk
     JOIN area_aggregated aa ON m4.area_aggregated_fk = aa.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE m3.scenario_demand_fk = mrp.scenario_demand_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY aa.name, my.year, dpv.id;

ALTER TABLE view_demand_profile_values
  OWNER TO postgres;
