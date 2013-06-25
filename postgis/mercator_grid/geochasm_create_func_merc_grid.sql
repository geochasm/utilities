DROP FUNCTION IF EXISTS gchsm_create_merc_grid(upper_left_start_in geometry(POINT), cell_side_meters_in numeric, numRows_in integer, numCols_in integer, output_tbl_in text);

CREATE FUNCTION gchsm_create_merc_grid(upper_left_start_in geometry(POINT), cell_side_meters_in numeric, numRows_in integer, numCols_in integer, output_tbl_in text) RETURNS integer AS $$


DECLARE

	grid_start_point geometry := upper_left_start_in;	
	start_x numeric := ST_X(upper_left_start_in);
	start_y numeric := ST_Y(upper_left_start_in);
	output_tbl text := output_tbl_in; --name of table created to store grid result
	input_SRID int := ST_SRID(grid_start_point);
	input_geometry_type text := ST_GeometryType(grid_start_point);	
	cell_side_meters numeric := cell_side_meters_in;
	numberRows integer := numRows_in;
	numberColumns integer :=numCols_in;
	cellsCreated integer := 0;
	gridGid integer := 0;
	gridRow integer := 1;
	gridColumn integer := 1;
	makePolygon text;
	makeGeom text;
	

BEGIN
	--check input geometry is point
	IF (input_geometry_type <> 'ST_Point')  THEN
		RAISE EXCEPTION 'INPUT GEOMETRY IS NOT A POINT';
		RETURN 0;
	END IF;
	--check SRID  = 3857
	IF (input_SRID <> 3857)  THEN
		RAISE EXCEPTION 'INPUT SRID NOT EQUAL TO 3857';
		RETURN 0;
	END IF;
	--check cell side size > 0
	IF (cell_side_meters <= 0)  THEN
		RAISE EXCEPTION 'CELL SIDE SIZE MUST BE > 0 METERS';
		RETURN 0;
	END IF;
	--check cell side size <= 1,000,000
	IF (cell_side_meters > 1000000)  THEN
		RAISE EXCEPTION 'CELL SIDE SIZE MUST BE <= 1,000,000 METERS';
		RETURN 0;
	END IF;
	--check that rows and columns > 1 
	IF (numberRows < 1 OR numberColumns < 1)  THEN
		RAISE EXCEPTION 'Row and Column must be >= 1';
		RETURN 0;
	END IF;
	--check output_tbl not null
	IF (output_tbl IS NULL OR upper(output_tbl) = 'NULL')  THEN
		RAISE EXCEPTION 'output_tbl MUST NOT BE NULL';
		RETURN 0;
	END IF;
	--check that lat value is within viable mercator north range of 70 degrees
	IF (start_y > 11068715.660)  THEN
		RAISE EXCEPTION 'START POINT Y VALUE MUST BE < 11068715.660 METERS';
		RETURN 0;
	END IF;
	--check that start_y value plus grid southern extents within viable mercator range
	IF (start_y - (numberRows*cell_side_meters) < -11068715.660)  THEN
		RAISE EXCEPTION 'Bottom Y extent of grid cannot be lower than -11068715.660 METERS';
		RETURN 0;
	END IF;


	--CAUTION - if function more than once with same output_tbl, former table dropped
	EXECUTE format('DROP TABLE IF EXISTS %s', output_tbl);
	
	--create table 
	EXECUTE format('
		CREATE TABLE %s (
			grid_id SERIAL, 
			grid_row integer,
			grid_column integer, 			
			geom_3857 geometry(Polygon,3857),
			CONSTRAINT %s_pkey PRIMARY KEY (grid_id)
			)', output_tbl, output_tbl);

	EXECUTE format('CREATE INDEX idx__%s_geom_3857 on %s USING GIST (geom_3857)',output_tbl, output_tbl);
		
	WHILE gridRow <= numberRows LOOP --outer loop once for each row
	
		WHILE gridColumn <= numberColumns LOOP --inner loop once for each column
		
			--create WKT Polygon
			makePolygon = 'POLYGON((' || start_x || ' ' || start_y || ',' --start coordinate
							|| start_x + cell_side_meters || ' ' || start_y || ',' --upper right coordinate
							|| start_x + cell_side_meters || ' ' || start_y - cell_side_meters || ',' --lower right coordinate
							|| start_x || ' ' || start_y - cell_side_meters ||',' --lower left coordinate
							|| start_x || ' ' || start_y --back to start coordinate
							||'))';
			--create geometry in SRID 3857
			makeGeom := ST_GeomFromText(makePolygon, 3857);

			--Inserts one grid cell record into output_tbl table
			EXECUTE format('INSERT INTO %s (grid_row, grid_column, geom_3857)values (%s,%s,%L)', 
					output_tbl, gridRow, gridColumn, makeGeom);									
					
			start_x := start_x + cell_side_meters; --increment start_x to origin point of next grid cell
			
			gridColumn := gridColumn + 1; --increment column 
			cellsCreated := cellsCreated +1; --increment cells created

		END LOOP; --END LOOP creating one row

		gridRow := gridRow +1;
		gridColumn := 1;
		start_x := start_x - (cell_side_meters * numberColumns); --resets start_x to original start_x		
		start_y := start_y - cell_side_meters; --decrement start_y to origin point of next lower row

	END LOOP; --End of loop creating all rows
	

	RAISE NOTICE 'cellsCreated is %', cellsCreated;

	RETURN cellsCreated;
	
	
END;
$$ LANGUAGE plpgsql;
--COMMENT ON FUNCTION