
CREATE OR REPLACE FUNCTION GET_DESCENDANT_LINES(PARENT_ID integer) RETURNS TABLE(LINE_ID integer) LANGUAGE 'sql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$

WITH RECURSIVE descendant_lines AS (
	SELECT
		T.line_id,
		T.parent_id
	FROM
		rf_hd_line T
	WHERE
		T.parent_id = $1 UNION ALL
	SELECT
		T.line_id,
		T.parent_id
	FROM
		rf_hd_line T JOIN descendant_lines dl ON T.parent_id = dl.line_id
	) SELECT line_id FROM descendant_lines;
$BODY$;