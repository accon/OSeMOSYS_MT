--CREATE OR REPLACE VIEW view_efficiency AS 
 SELECT e.*
    
   FROM efficiency e,
--     JOIN mapping_efficiency_scenario mes ON e.id = mes.efficiency_fk,
--     JOIN scenario_efficiency se ON mes.scenario_efficiency_fk = se.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
 -- WHERE se.id = mrp.modelling_set_emission_fk AND mrp.id = cmrp.modelling_run_properties_fk;
