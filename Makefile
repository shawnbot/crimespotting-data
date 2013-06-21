BASE_URL ?= http://apps.sfgov.org/datafiles/view.php?file=Police

DB_FILE ?= archive.db
DB_EXEC ?= sqlite3 $(DB_FILE)
DB_JDBC ?= "sqlite:///$(DB_FILE)"

all: $(DB_FILE) update-90d sync

$(DB_FILE):
	$(DB_EXEC) < sql/create.sql

sync: $(DB_FILE)
	$(DB_EXEC) < sql/sync.sql

flush:
	$(DB_EXEC) < sql/create.sql

update: $(FILE) $(DB_FILE)
	$(call update_with_file,$(FILE))

update-archive: download/archive.csv $(DB_FILE)
	$(call update_with_file,$<)

update-daily: download/delta-daily.csv $(DB_FILE)
	$(call update_with_file,$<)

update-weekly: download/delta-weekly.csv $(DB_FILE)
	$(call update_with_file,$<)

update-90d: download/delta-90d.csv $(DB_FILE)
	$(call update_with_file,$<)

download/archive.csv: download
	cd download && \
		curl -O $(BASE_URL)/sfpd_incident_all_csv.zip && \
		unzip sfpd_incident_all_csv.zip && \
		head -1 sfpd_incident_`date +%Y`.csv > archive.csv && \
		cat sfpd_incident_????.csv | egrep -v IncidntNum >> archive.csv
	$(call repair_csv,$@)

download/delta-daily.csv: download
	# download daily delta
	curl $(BASE_URL)/incident_changes_from_previous_day.json > download/delta-daily.json
	# convert from GeoJSON to CSV
	./tools/ogr2csv.sh download/delta-daily.json $@
	$(call repair_csv,$@)

download/delta-weekly.csv: download
	# download daily delta
	curl $(BASE_URL)/one_week_city_wide_incidents.json > download/delta-weekly.json
	# convert from GeoJSON to CSV
	./tools/ogr2csv.sh download/delta-weekly.json $@
	$(call repair_csv,$@)

download/delta-90d.csv: download
	cd download && \
		curl -O $(BASE_URL)/CrimeIncidentShape_90-All.zip && \
		unzip -o CrimeIncidentShape_90-All.zip
	# convert from Shapefile to CSV
	./tools/ogr2csv.sh download/incidcomshape.shp $@
	$(call repair_csv,$@)

download:
	mkdir -p $@

clean:
	rm -rf download/*
	$(DB_EXEC) < sql/flush-updates.sql

distclean: clean
	if [ -f $(DB_FILE) ]; then \
		rm -f $(DB_FILE); \
	fi

define update_with_file
	$(DB_EXEC) < sql/flush-updates.sql
	csvsql --db $(DB_JDBC) --insert --no-create --table updates < $1
	$(DB_EXEC) < sql/sync.sql
endef

define repair_csv
	python tools/repair.py $@ > $@.repaired
	mv $@.repaired $@
endef
