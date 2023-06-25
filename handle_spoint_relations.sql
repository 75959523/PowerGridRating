
CREATE OR REPLACE FUNCTION HANDLE_SPOINT_RELATIONS() RETURNS VOID LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE AS $BODY$

BEGIN
	UPDATE temp_data T
		SET s_tower_id = t2.s_tower_id
	FROM
		temp_data t2
	WHERE
		T.rel_tower_code = t2.prev_tower_code
		AND T.rel_line_name = SUBSTRING ( t2.line_name, 1, POSITION ( '#' IN t2.line_name ) - 1 )
		AND T.prev_tower_code = 1
		AND T.voltage <= t2.voltage;
END
$BODY$;