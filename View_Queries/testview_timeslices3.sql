SELECT 	ts.pk,
	ts.name,
	season.name,
	daytype.name,
	daylitimebracket.name,
	ts.hours_per_timeslice,
	m.starting_timeslice_fk,
	m.hourly_time_block_fk
--	hourly_time_block.id,
--	hourly_time_block.name,
--	hourly_time_block.yearly_hour_start,
--	hourly_time_block.length__h
FROM 	timeslice ts
		INNER JOIN mapping_hourly_time_blocks_timeslices m
			ON ts.pk = m.starting_timeslice_fk,
	season,
	daytype,
	daylitimebracket,
	hourly_time_block

