BASE_URL ?= http://apps.sfgov.org/datafiles/view.php?file=Police
IN_COLUMNS ?= IncidntNum,Category,Descript,DayOfWeek,Date,Time,PdDistrict,Resolution,Location,X,Y

DB ?= archive.db
TABLE ?= updates

all: $(DB) update-90d sync

$(DB):
	sqlite3 $(DB) < create.sql

sync: $(DB)
	sqlite3 $(DB) < sync.sql

flush:
	sqlite3 $(DB) < create.sql

update: $(FILE) $(DB)
	$(call _insert,$(FILE),updates)

update-archive: download/archive.csv $(DB)
	$(call _insert,$<,updates)

update-daily: download/delta-daily.csv $(DB)
	$(call _insert,$<,updates)

update-weekly: download/delta-weekly.csv $(DB)
	$(call _insert,$<,updates)

update-90d: download/delta-90d.csv $(DB)
	$(call _insert,$<,updates)

download/archive.csv: download
	cd download && \
		curl -O $(BASE_URL)/sfpd_incident_all_csv.zip && \
		unzip sfpd_incident_all_csv.zip && \
		head -1 sfpd_incident_`date +%Y`.csv > archive.csv && \
		cat sfpd_incident_????.csv | egrep -v IncidntNum >> archive.csv
	$(call _repair,$@)

download/delta-daily.csv: download
	# download daily delta
	curl $(BASE_URL)/incident_changes_from_previous_day.json > download/delta-daily.json
	# convert from GeoJSON to CSV
	./tools/ogr2csv.sh download/delta-daily.json $@
	$(call _repair,$@)

download/delta-weekly.csv: download
	# download daily delta
	curl $(BASE_URL)/one_week_city_wide_incidents.json > download/delta-weekly.json
	# convert from GeoJSON to CSV
	./tools/ogr2csv.sh download/delta-weekly.json $@
	$(call _repair,$@)

download/delta-90d.csv: download
	cd download && \
		curl -O $(BASE_URL)/CrimeIncidentShape_90-All.zip && \
		unzip -o CrimeIncidentShape_90-All.zip
	# convert from Shapefile to CSV
	./tools/ogr2csv.sh download/incidcomshape.shp $@
	$(call _repair,$@)

download:
	mkdir -p $@

clean:
	rm -rf download/*
	-sqlite3 $(DB) "DELETE FROM updates;" >> /dev/null

distclean: clean
	rm -f archive.db

define _insert
	csvsql --db "sqlite:///$(DB)" --insert --no-create --table $2 < $1
endef

define _repair
	python tools/repair.py $@ > $@.repaired
	mv $@.repaired $@
endef
