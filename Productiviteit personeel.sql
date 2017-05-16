SELECT
  SUBQ2.Werkgever,
  sum(SUBQ2.Direct) / (sum(SUBQ2.Direct) + sum(SUBQ2.Indirect)) AS Productiviteit

FROM
  (
    SELECT
      SUBQ.Werkgever,
      CASE
        WHEN SUBQ.Type = 'Indirect' THEN SUBQ.Uren
        ELSE 0
      END AS Indirect,
      CASE
        WHEN SUBQ.Type = 'Direct' THEN SUBQ.Uren
        ELSE 0
      END AS Direct
    FROM
      (
        SELECT
          dbo.tblPersoneel.Werkgever,
          dbo.tblPersoneel.PersoneelNo,
          dbo.tblPersoneel.VolledigeNaam,
          CASE
            WHEN len(dbo.tblUrenRegistratieRegel.ProjectNr) = 4 THEN 'Indirect'
            WHEN len(dbo.tblUrenRegistratieRegel.ProjectNr) = 8 THEN 'Direct'
          END AS Type,
          dbo.tblUrenRegistratieRegel.Uren,
          dbo.zLookupYearDays.YeardateYear
        FROM
          dbo.tblUrenRegistratieRegel
        JOIN dbo.tblPersoneel
          ON dbo.tblUrenRegistratieRegel.PersoneelID = dbo.tblPersoneel.PersoneelID
        JOIN dbo.zLookupYearDays
          ON dbo.zLookupYearDays.Yeardate = dbo.tblUrenRegistratieRegel.DatumUrenReg
        WHERE
          dbo.zLookupYearDays.YeardateYear = 2016
      ) AS SUBQ
  ) AS SUBQ2
GROUP BY SUBQ2.Werkgever
