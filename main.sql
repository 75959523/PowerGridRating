
CREATE OR REPLACE PROCEDURE MAIN(IN PARENT_ID integer, IN BASE_TOWER_ID integer) LANGUAGE 'plpgsql' AS $BODY$
DECLARE
    line_ids TEXT;
BEGIN
    line_ids = get_line_ids(parent_id);

    PERFORM initialize_data(line_ids, parent_id, base_tower_id);

    PERFORM handle_epoint_relations();

    PERFORM handle_spoint_relations();

    PERFORM get_result();
END;
$BODY$;