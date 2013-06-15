SELECT category, COUNT(*) as size
FROM reports
GROUP BY category
ORDER BY size DESC;
