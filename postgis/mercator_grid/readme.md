<strong>PostGIS Mercator Grid Create function</strong>

<p>This PL/pgSQL function can be installed in your database by executing the geochasm_create_func_merc_grid.sql script</p>

<p>The resulting function can be called using gchsm_create_merc_grid() with the required 5 parameters.</p>

<p>The parameters are as follows:</p><br/>
<p><strong>upper_left_start_in geometry(POINT)</strong>: Upper left hand corner starting point for the grid.
Grid will be built right and down from this point. Point must be SRID 3857 with Y value
between -11068715.660 and 11068715.660</p>

<p><strong>cell_side_meters_in numeric</strong>: Desired length of cell side in meters; cells are square so require only one side value</p>
<p><strong>numRows_in integer</strong>: Desired number of rows; must be an integer</p>
<p><strong>numCols_in integer</strong>: Desired number of columns; must be an integer</p>
<p><strong>output_tbl_in text</strong>: Name of output table for storage of resulting grid. Table will contain one row per grid cell. 
Each table row will contain row and column values for the grid cell. If same output_tbl used in consecutive calls,
previous table will be dropped	</p>

<p><strong>Comments on use</strong></p>

<p>The function forces SRID 3857 for a few reasons. 
First, cell size is submitted in meters, instead of something like decimal degrees.
Use ST_TRANSFORM (Geometry, 3857) to convert your non-3857 point.</p>
<p>Second, this slightly simplifies the code that calculates the cell corner coordinates</p>
<p>There is no limit to number of rows or number of cells. 
However, you should be aware the creating a 10 meter grid covering the entire world may take a long time.
Be aware of the number of cells in your grid as it relates to processing time.</p>
<p>The limitation on Y value assumes that SRID 3857 is somewhat unusable 
above 70 degrees north and below 70 degrees south. You can remove this constraint simply 
by removing the relevant If clauses around line 57 of the script.</p>



