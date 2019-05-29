-- View: view_storage

DROP VIEW view_storage;

CREATE OR REPLACE VIEW view_storage AS 
 SELECT DISTINCT st.id,
    st.name,
    st.capacity__mwh,
    st.storage_type_fk,
    st.efficiency_charge,
    st.efficiency_discharge,
    st.commissioning_year,
    st.degradation_rate__percent_a,
    st.capacity_to_max_power_average__h,
    st.min_charge_level__mwh,
    stt.max_charge_rate_average__mw,
    stt.max_discharge_rate_average__mw,
    stt.name AS storage_type_name,
    stt.lifetime__a AS storage_lifetime__a
   FROM storage st
     JOIN storage_type stt ON st.storage_type_fk = stt.id
     JOIN storage_cost stc ON stt.id = stc.storage_type_fk
     JOIN mapping_scenario_storage_cost m ON stc.id = m.storage_cost_fk
     JOIN scenario_storage_cost scstc ON m.scenario_storage_cost_fk = scstc.id,
    modelling_run_properties mrp,
    choice_modelling_run_properties cmrp
  WHERE scstc.id = mrp.scenario_storage_cost_fk AND mrp.id = cmrp.modelling_run_properties_fk
  ORDER BY st.id;