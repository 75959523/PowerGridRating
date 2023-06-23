CREATE OR REPLACE FUNCTION "get_descendant_lines"("parent_id" int4)
  RETURNS TABLE("line_id" int4) AS $BODY$ 
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
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000