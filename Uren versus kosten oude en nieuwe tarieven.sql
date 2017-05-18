SELECT
  dbo.tblPersoneel.Werkgever,
  dbo.tblPersoneel.CAO,
  dbo.tblPersoneel.PersoneelNo,
  dbo.tblPersoneel.Beroep,
  dbo.tblPersoneel.VolledigeNaam,
  dbo.tblPersoneel.Actief,
  dbo.tblPersoneel.TariefIntern,
  dbo.tblPersoneel.TariefNieuw,
  dbo.tblPersoneel.TariefIntern * dbo.tblUrenRegistratieRegel.Uren AS KostenOud,
  dbo.tblPersoneel.TariefNieuw * dbo.tblUrenRegistratieRegel.Uren AS KostenNieuw,
  dbo.zLookupYearDays.YeardateYear,
  dbo.tblUrenRegistratieRegel.ProjectNr,
case
  WHEN left(right(dbo.tblUrenRegistratieRegel.ProjectNr, 8), 3) = 999 THEN '999x'
  WHEN left(right(dbo.tblUrenRegistratieRegel.ProjectNr, 8), 2) = 61 THEN '61xxxxxx'
  ELSE 'IC'
END AS Type,
  dbo.tblUrenRegistratieRegel.Uren,
  dbo.zLookupAlgemeen.Waarde,
  dbo.zLookupBedrijven.Bedrijfsnaam
FROM
  dbo.tblUrenRegistratieRegel
JOIN dbo.tblPersoneel
  ON dbo.tblUrenRegistratieRegel.PersoneelID = dbo.tblPersoneel.PersoneelID
JOIN dbo.zLookupYearDays
  ON dbo.zLookupYearDays.Yeardate = dbo.tblUrenRegistratieRegel.DatumUrenReg
JOIN dbo.zLookupAlgemeen
  ON dbo.tblPersoneel.PersoneelType = dbo.zLookupAlgemeen.ID
JOIN dbo.zLookupBedrijven
  ON dbo.tblPersoneel.WerkgeverBV = dbo.zLookupBedrijven.BedrijfsID
WHERE
  dbo.tblPersoneel.WerkgeverBV = 2
