CREATE OR REPLACE PROCEDURE "main"("parent_id" int4, "base_tower_id" int4)
 AS $BODY$
DECLARE
    line_ids TEXT;
BEGIN
    CREATE TABLE temp_line_ids (id INT);
		
    INSERT INTO temp_line_ids (id) VALUES (parent_id);

    INSERT INTO temp_line_ids (id) SELECT get_descendant_lines(parent_id);

    SELECT string_agg(id::text, ',') INTO line_ids FROM temp_line_ids;

    DROP TABLE temp_line_ids;

    PERFORM initialize_data(line_ids, parent_id, base_tower_id);

    PERFORM handle_epoint_relations();

    PERFORM handle_spoint_relations();

    PERFORM get_result();
END;
$BODY$
  LANGUAGE plpgsql