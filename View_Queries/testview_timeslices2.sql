SELECT 	ts.pk,
	ts.name,
	ts.hours_per_timeslice,
	s.name,
	dt.name,
	dtb.name,
	m.hourly_time_block_fk
FROM 	timeslice ts
--		LEFT JOIN mapping_hourly_time_blocks_timeslices m 
--			ON m.starting_timeslice_fk = ts.pk
		INNER JOIN season s
			ON ts.season_fk = s.season_pk
		INNER JOIN daytype dt
			ON ts.daytype_fk = dt.pk
		JOIN daylitimebracket dtb
			ON ts.dailytimebracket_fk = dtb.pk,
	mapping_hourly_time_blocks_timeslices m

GROUP BY ts.pk
ORDER BY ts.pk	
--AND 	hourly_time_block.id = mapping_hourly_time_blocks_timeslices.hourly_time_block_fk
--AND 	timeslice.pk = mapping_hourly_time_blocks_timeslices.starting_timeslice_fk

