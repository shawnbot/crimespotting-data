#!/bin/sh
ogr2ogr -F CSV -lco GEOMETRY=AS_XY -t_srs EPSG:4326 $2_dir $1
mv $2_dir/*.csv $2
rm -r $2_dir
