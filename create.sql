DROP TABLE IF EXISTS updates;
CREATE TABLE updates (
    "id"            INTEGER PRIMARY KEY AUTOINCREMENT,
    "IncidntNum"    INTEGER NOT NULL,
    "Category"      VARCHAR(32),
    "Descript"      VARCHAR(64),
    "type"          VARCHAR(64),
    "DayOfWeek"     VARCHAR(10),
    "Date"          DATE,
    "Time"          TIME,
    "PdDistrict"    VARCHAR(10),
    "Resolution"    VARCHAR(32),
    "Location"      VARCHAR(64),
    "X"             FLOAT,
    "Y"             FLOAT
);

DROP TABLE IF EXISTS reports;
CREATE TABLE reports (
    "id"            INTEGER PRIMARY KEY AUTOINCREMENT,
    "case_number"   INTEGER NOT NULL,
    "category"      VARCHAR(32),
    "description"   VARCHAR(64),
    "type"          VARCHAR(64),
    "date"          DATE NOT NULL,
    "time"          TIME NOT NULL,
    "district"      VARCHAR(10) NOT NULL,
    "resolution"    VARCHAR(32),
    "location"      VARCHAR(64),
    "longitude"     FLOAT NOT NULL,
    "latitude"      FLOAT NOT NULL,
    "notes"         TEXT
);

CREATE UNIQUE INDEX report_key
    ON reports (case_number, category, description, date, time);

CREATE INDEX report_date ON reports (date, time);
CREATE INDEX report_type ON reports (type);
