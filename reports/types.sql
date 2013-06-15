SELECT canonical_type, COUNT(*) as size
FROM reports
GROUP BY canonical_type
ORDER BY size DESC;
