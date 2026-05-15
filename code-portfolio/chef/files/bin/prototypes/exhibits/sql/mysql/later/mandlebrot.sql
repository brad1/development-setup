WITH    RECURSIVE
        q (r, i, rx, ix, g) AS
        (
        SELECT  r::DOUBLE PRECISION * 0.02, i::DOUBLE PRECISION * 0.02, .0::DOUBLE PRECISION, .0::DOUBLE PRECISION, 0
        FROM    generate_series(-60, 20) r, generate_series(-50, 50) i
        UNION ALL
        SELECT  r, i, CASE WHEN ABS(rx * rx + ix * ix) <= 2 THEN rx * rx - ix * ix END + r, CASE WHEN ABS(rx * rx + ix * ix) <= 2 THEN 2 * rx * ix END + i, g + 1
        FROM    q
        WHERE   rx IS NOT NULL
                AND g < 99
        )
SELECT  ARRAY_TO_STRING(ARRAY_AGG(s ORDER BY r), '')
FROM    (
        SELECT  i, r, SUBSTRING(' .:-=+*#%@', MAX(g) / 10 + 1, 1) s
        FROM    q
        GROUP BY
                i, r
        ) q
GROUP BY
        i
ORDER BY
        i
