SELECT description, COUNT(*) as size
FROM reports
GROUP BY description
--HAVING size > 1
ORDER BY size DESC;
