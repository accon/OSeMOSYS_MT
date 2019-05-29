--CREATE OR REPLACE VIEW view_power_plant_info AS 
 SELECT pp.id AS pp_type_id,
	pp.efficiency AS pp_efficiency,
	st.efficiency_charge AS storage_charge_efficiency,
	st.efficiency_discharge AS storage_discharge_efficiency
    
   FROM power_plant_type ppt
     JOIN power_plant_cost ppc ON ppt.id = ppc.power_plant_type_fk
     JOIN mapping_power_plant_cost_scenario m ON ppc.id = m.power_plant_cost_fk
     JOIN scenario_power_plant_cost scppc ON m.scenario_power_plant_cost_fk = scppc.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE scppc.id = mrp.scenario_power_plant_cost_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY ppt.id;

ALTER TABLE view_power_plant_info
  OWNER TO postgres;
COMMENT ON VIEW view_power_plant_info
  IS 'Maybe ammend this view to extract more additional information
';
