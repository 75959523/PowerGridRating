
CREATE OR REPLACE FUNCTION GET_LINE_IDS(PARENT_ID integer) RETURNS text LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE AS $BODY$
DECLARE
    line_ids TEXT;
BEGIN
    WITH line_ids_cte AS (
        SELECT parent_id as id
        UNION ALL
        SELECT get_descendant_lines(parent_id)
    )
    SELECT string_agg(id::text, ',') INTO line_ids FROM line_ids_cte;

    RETURN line_ids;
END;
$BODY$;