SELECT strftime('%Y', `date`) AS year, COUNT(*) as size
FROM reports
GROUP BY year
ORDER BY size DESC;

SELECT strftime('%Y/%m', `date`) AS year_month, COUNT(*) as size
FROM reports
GROUP BY year_month
ORDER BY year_month DESC;

SELECT strftime('%Y/%m/%d', `date`) AS day, COUNT(*) as size
FROM reports
GROUP BY day
ORDER BY day DESC;
