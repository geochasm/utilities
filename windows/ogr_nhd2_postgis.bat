@ECHO OFF

::This script is offered under the MIT license at http://opensource.org/licenses/MIT
::Copyright(c) 2013 Geochasm http://geochasm.com/

::Test this script prior to using; this script may damage existing data

ECHO Script Started  . . . 

::replace with path to your directory of NHD medium res .mdb files
::needs to end with a backslash (\)
set nhdPath=C:\GEODATA\NHD\RB_Temp\

::replace values below with your PostGIS db connection string values
set pg_db_connect_string=PG:"port=5432 user=postgres dbname=yourDb password=yourDbPassword"

::prompt user for layer name, for example 'nhdflowline'
set /p shapeLayer=Enter Layer Name:

::loop through all files located at nhdpath, import layer entered above
::note that the '*' after %nhdpath% is a wildcard so for loop
::reads all files in %nhdpath% directory
for %%f in (%nhdpath%*) do (
	ECHO Importing %shapeLayer%
	ECHO  from %%f	
	ECHO to %pg_db_connect_string%
	START /B /WAIT OGR2OGR -f "PostgreSQL" %pg_db_connect_string% %%f %shapeLayer% -append -skipfailures
	)

PAUSE