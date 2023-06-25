
CREATE OR REPLACE FUNCTION HANDLE_EPOINT_RELATIONS() RETURNS VOID LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE AS $BODY$

BEGIN
	WITH tab AS (
		SELECT
			*
		FROM
			temp_data T
		WHERE
			T.base_line_name = SUBSTRING ( T.line_name, 1, POSITION ( '#' IN T.line_name ) - 1 )
		ORDER BY prev_tower_code DESC LIMIT 1
		) UPDATE temp_data T SET s_tower_id = tab.e_tower_id
	FROM
		tab
	WHERE
		T.rel_tower_code = tab.prev_tower_code + 1
		AND T.rel_line_name = SUBSTRING ( tab.line_name, 1, POSITION ( '#' IN tab.line_name ) - 1 )
		AND T.prev_tower_code = 1
		AND T.voltage <= tab.voltage;
END;
$BODY$;