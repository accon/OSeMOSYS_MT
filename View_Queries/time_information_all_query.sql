CREATE VIEW time_information_complete AS
SELECT 	ts.pk AS timeslice_id,
	ts.name AS timeslice_name,
	ts.hours_per_timeslice,
	s.name AS season_name,
	dt.name AS daytype_name,
	dtb.name AS dtb_name,
	htb.name AS htb_name,
	htb.yearly_hour_start,
	htb.length__h,
	shtb.name AS shtb_name,
	m3.name AS mapping_name,
	my.year AS modelling_year,
	st.name AS time_scenario_name
	
FROM 	timeslice ts
		INNER JOIN mapping_hourly_time_blocks_timeslices m 
			ON m.starting_timeslice_fk = ts.pk
		INNER JOIN season s
			ON ts.season_fk = s.season_pk
		INNER JOIN daytype dt
			ON ts.daytype_fk = dt.pk
		JOIN daylitimebracket dtb
			ON ts.dailytimebracket_fk = dtb.pk
		JOIN hourly_time_block htb
			ON m.hourly_time_block_fk = htb.id
		JOIN mapping_set_hourly_time_blocks_htb m2
			ON m.hourly_time_block_fk = m2.hourly_time_block_fk
		JOIN set_hourly_time_block shtb
			ON m2.set_hourly_time_block_fk = shtb.id
		JOIN mapping_modelling_year_set_htb m3
			ON m2.set_hourly_time_block_fk = m3.set_hourly_time_block_fk
		JOIN modelling_year my
			ON m3.modelling_year_fk = my.id
		JOIN mapping_scenario_time_set_map_modyr_set_htb m4
			ON m3.id = m4.mapping_modyr_set_htb_fk
		JOIN scenario_time st
			ON m4.scenario_time_fk = st.id,
	modelling_run_properties mrp,
	choice_modelling_run_properties cmrp

WHERE st.id = mrp.scenario_time_fk
AND mrp.scenario_time_fk = cmrp.modelling_run_properties_fk

ORDER BY my.year, ts.pk	

