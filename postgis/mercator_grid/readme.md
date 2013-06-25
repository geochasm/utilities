PostGIS Mercator Grid Create function

This PL/pgSQL function can be installed in your database by executing the geochasm_create_func_merc_grid.sql script

The resulting function can be called using gchsm_create_merc_grid() with the required 5 parameters.

The parameters are as follows:
	<strong>upper_left_start_in geometry(POINT)</strong>:
	<strong>cell_side_meters_in numeric</strong>:
	<strong>numRows_in integer</strong>:
	<strong>numCols_in integer</strong>:
	<strong>output_tbl_in text</strong>:


