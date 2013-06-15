INSERT OR REPLACE INTO reports (
    "case_number",
    "category",
    "description",
    "type",
    "date",
    "time",
    "district",
    "resolution",
    "location",
    "longitude",
    "latitude"
) SELECT 
    IncidntNum,
    Category,
    Descript,
    type,
    Date,
    Time,
    PdDistrict,
    Resolution,
    Location,
    X,
    Y
FROM updates
WHERE
    type IS NOT NULL
    AND X IS NOT NULL
    AND Y IS NOT NULL
    AND Date IS NOT NULL
    AND Time IS NOT NULL
    AND PdDistrict IS NOT NULL
    AND Category IS NOT NULL
    AND Category != 'NON-CRIMINAL';
