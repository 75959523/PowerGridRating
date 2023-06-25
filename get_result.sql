
CREATE OR REPLACE FUNCTION GET_RESULT() RETURNS VOID LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE AS $BODY$

BEGIN
	DROP TABLE IF EXISTS RESULT;
	CREATE TABLE RESULT AS WITH tab AS (
		WITH RECURSIVE T ( root_tower_id, s_tower_id, e_tower_id, distance, DEPTH, line_id, voltage ) AS (
			SELECT
				s_tower_id AS root_tower_id,
				s_tower_id,
				e_tower_id,
				distance,
				1 AS DEPTH,
				line_id,
				voltage
			FROM
				temp_data UNION ALL
			SELECT
				T.root_tower_id,
				d.s_tower_id,
				d.e_tower_id,
				d.distance + T.distance,
				T.DEPTH + 1 AS DEPTH,
				d.line_id,
				d.voltage
			FROM
				temp_data d
				JOIN T ON ( d.s_tower_id = T.e_tower_id )
			) SELECT * FROM T
		),
		tab2 AS (
		SELECT
			T.*,
			ROW_NUMBER ( ) OVER ( PARTITION BY T.e_tower_id, T.s_tower_id ) rn,
			COUNT ( * ) OVER ( PARTITION BY T.e_tower_id, T.s_tower_id ) cnt
		FROM tab T
		) SELECT
		root_tower_id,
		s_tower_id,
		e_tower_id,
		distance,
		DEPTH,
		line_id,
		voltage
	FROM
		tab2
	WHERE
		cnt = rn
	ORDER BY
		distance DESC;
END;
$BODY$;