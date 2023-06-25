
CREATE OR REPLACE FUNCTION INITIALIZE_DATA(LINE_ID_LIST text, PARENT_ID integer, BASE_TOWER_ID integer) RETURNS VOID LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE AS $BODY$
DECLARE
    line_id_record RECORD;
    tower_id_record RECORD;
    prev_tower_id INTEGER;
    current_tower_id INTEGER;
    distance FLOAT;
		line_name VARCHAR;
		prev_tower_code INTEGER;
		rel_tower_code INTEGER;
		rel_line_name VARCHAR;
		base_line_name VARCHAR;
		base_tower_name VARCHAR;
		voltage FLOAT;
BEGIN
    DROP TABLE IF EXISTS temp_data;
    CREATE TABLE temp_data (
        distance FLOAT,
        s_tower_id INTEGER,
        e_tower_id INTEGER,
        line_id INTEGER,
				line_name VARCHAR,
				prev_tower_code INTEGER,
				rel_tower_code INTEGER,
				rel_line_name VARCHAR,
				base_line_name VARCHAR,
				base_tower_name VARCHAR,
				voltage FLOAT
    );

		FOR line_id_record IN
        SELECT unnest(string_to_array(line_id_list, ','))::INTEGER AS line_id
    LOOP
				SELECT replace(rf_hd_line.voltage, 'kV', '') INTO voltage FROM rf_hd_line WHERE line_id = line_id_record.line_id;
        FOR tower_id_record IN
            SELECT tower_id
            FROM rf_hd_tower
            WHERE line_id = line_id_record.line_id
            ORDER BY tower_id
            OFFSET 1
        LOOP
            prev_tower_id := tower_id_record.tower_id - 1;
            current_tower_id := tower_id_record.tower_id;

            SELECT ST_Distance(
								ST_Transform(ST_SetSRID(ST_MakePoint(CAST(prev_tower.lon AS FLOAT), CAST(prev_tower.lat AS FLOAT)), 4326), 3857),
								ST_Transform(ST_SetSRID(ST_MakePoint(CAST(current_tower.lon AS FLOAT), CAST(current_tower.lat AS FLOAT)), 4326), 3857)
            ) INTO distance
            FROM rf_hd_tower AS prev_tower, rf_hd_tower AS current_tower
            WHERE prev_tower.tower_id = prev_tower_id
            AND current_tower.tower_id = current_tower_id;

            SELECT prev_tower.tower_name || ' ' || current_tower.tower_name INTO line_name
            FROM rf_hd_tower AS prev_tower, rf_hd_tower AS current_tower
            WHERE prev_tower.tower_id = prev_tower_id
            AND current_tower.tower_id = current_tower_id;

						SELECT rf_hd_tower.tower_code INTO prev_tower_code FROM rf_hd_tower where tower_id = prev_tower_id;
						SELECT CAST(COALESCE(NULLIF(rf_hd_tower.rel_tower_code, ''), '0') AS INTEGER) INTO rel_tower_code FROM rf_hd_tower where tower_id = prev_tower_id;
						SELECT rf_hd_tower.rel_line_name INTO rel_line_name FROM rf_hd_tower where tower_id = prev_tower_id;
						SELECT rf_hd_line.line_name INTO base_line_name FROM rf_hd_line where line_id = initialize_data.parent_id;
						SELECT rf_hd_tower.tower_name INTO base_tower_name from rf_hd_tower where tower_id = base_tower_id;

            INSERT INTO temp_data (distance, s_tower_id, e_tower_id, line_id, line_name, prev_tower_code, rel_tower_code, rel_line_name, base_line_name, base_tower_name, voltage)
            VALUES (distance, prev_tower_id, current_tower_id, line_id_record.line_id, line_name, prev_tower_code, rel_tower_code, rel_line_name, base_line_name, base_tower_name, voltage);

        END LOOP;
    END LOOP;
END;
$BODY$;