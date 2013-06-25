PostGIS Mercator Grid Create function

This PL/pgSQL function can be installed in your database by executing the geochasm_create_func_merc_grid.sql script

The resulting function can be called using gchsm_create_merc_grid() with the required 5 parameters.

<p>The parameters are as follows:</p><br/>
<p><strong>upper_left_start_in geometry(POINT)</strong>: Upper left hand corner starting point for the grid.
Grid will be built right and down from this point. Point must be SRID 3857 with Y value
between -11068715.660 and 11068715.660</p>

<p><strong>cell_side_meters_in numeric</strong>: Desired length of cell side in meters</p>
<p><strong>numRows_in integer</strong>: Desired number of rows; must be an integer</p>
<p><strong>numCols_in integer</strong>: Desired number of columns; must be an integer</p>
<p><strong>output_tbl_in text</strong>: Name of output table for storage of resulting grid. Table will contain one row per grid cell. 
Each table row will contain row and column values for the grid cell. If same output_tbl used in consecutive calls,
previous table will be dropped</p>


