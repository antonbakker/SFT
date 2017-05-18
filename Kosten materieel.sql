SELECT
'Materieel' AS MaterieelType,
dbo.zLookupBedrijven.Bedrijfsnaam,
dbo.tblMaterieel.KostenPlaats,
dbo.tblMaterieel.Groep,
dbo.tblMaterieel.Omschrijving,
dbo.tblMaterieel.Kenteken,
dbo.zLookupYearDays.YeardateYear,
dbo.tblUrenRegistratieRegel.ProjectNr,
dbo.tblUrenRegistratieRegel.Werkzaamheden,
dbo.tblUrenRegistratieRegel.Uren,
dbo.tblMaterieel.TariefIntern,
dbo.tblUrenRegistratieRegel.Uren * dbo.tblMaterieel.TariefIntern AS KostenIntern,
case
WHEN left(right(dbo.tblUrenRegistratieRegel.ProjectNr, 8), 3) = 999 THEN '999x'
WHEN left(right(dbo.tblUrenRegistratieRegel.ProjectNr, 8), 2) = 61 THEN '61xxxxxx'
ELSE 'IC'
END AS Type,
CASE
WHEN right(dbo.tblUrenRegistratieRegel.ProjectNr,4) IN ('4400','4450') THEN 'Onderhoud'
ELSE 'Productie'
END AS Productie
FROM
dbo.zLookupYearDays
JOIN dbo.tblUrenRegistratieRegel
ON dbo.zLookupYearDays.Yeardate = dbo.tblUrenRegistratieRegel.DatumUrenReg
JOIN dbo.tblMaterieel
ON dbo.tblMaterieel.MaterieelID = dbo.tblUrenRegistratieRegel.MaterieelID
JOIN dbo.zLookupBedrijven
ON dbo.tblMaterieel.GebruikerBV = dbo.zLookupBedrijven.BedrijfsID
WHERE
dbo.tblMaterieel.Actief = 1

UNION ALL

SELECT
'Hulpstuk1' AS MaterieelType,
dbo.zLookupBedrijven.Bedrijfsnaam,
dbo.tblMaterieel.KostenPlaats,
dbo.tblMaterieel.Groep,
dbo.tblMaterieel.Omschrijving,
dbo.tblMaterieel.Kenteken,
dbo.zLookupYearDays.YeardateYear,
dbo.tblUrenRegistratieRegel.ProjectNr,
dbo.tblUrenRegistratieRegel.Werkzaamheden,
dbo.tblUrenRegistratieRegel.Uren,
dbo.tblMaterieel.TariefIntern,
dbo.tblUrenRegistratieRegel.Uren * dbo.tblMaterieel.TariefIntern AS KostenIntern,
case
WHEN left(right(dbo.tblUrenRegistratieRegel.ProjectNr, 8), 3) = 999 THEN '999x'
WHEN left(right(dbo.tblUrenRegistratieRegel.ProjectNr, 8), 2) = 61 THEN '61xxxxxx'
ELSE 'IC'
END AS Type,
CASE
WHEN right(dbo.tblUrenRegistratieRegel.ProjectNr,4) IN ('4400','4450') THEN 'Onderhoud'
ELSE 'Productie'
END AS Productie
FROM
dbo.zLookupYearDays
JOIN dbo.tblUrenRegistratieRegel
ON dbo.zLookupYearDays.Yeardate = dbo.tblUrenRegistratieRegel.DatumUrenReg
JOIN dbo.tblMaterieel
ON dbo.tblMaterieel.MaterieelID = dbo.tblUrenRegistratieRegel.HulpstukId
JOIN dbo.zLookupBedrijven
ON dbo.tblMaterieel.GebruikerBV = dbo.zLookupBedrijven.BedrijfsID
WHERE
dbo.tblMaterieel.Actief = 1

UNION ALL

SELECT
'Hulpstuk2' AS MaterieelType,
dbo.zLookupBedrijven.Bedrijfsnaam,
dbo.tblMaterieel.KostenPlaats,
dbo.tblMaterieel.Groep,
dbo.tblMaterieel.Omschrijving,
dbo.tblMaterieel.Kenteken,
dbo.zLookupYearDays.YeardateYear,
dbo.tblUrenRegistratieRegel.ProjectNr,
dbo.tblUrenRegistratieRegel.Werkzaamheden,
dbo.tblUrenRegistratieRegel.Uren,
dbo.tblMaterieel.TariefIntern,
dbo.tblUrenRegistratieRegel.Uren * dbo.tblMaterieel.TariefIntern AS KostenIntern,
case
WHEN left(right(dbo.tblUrenRegistratieRegel.ProjectNr, 8), 3) = 999 THEN '999x'
WHEN left(right(dbo.tblUrenRegistratieRegel.ProjectNr, 8), 2) = 61 THEN '61xxxxxx'
ELSE 'IC'
END AS Type,
CASE
WHEN right(dbo.tblUrenRegistratieRegel.ProjectNr,4) IN ('4400','4450') THEN 'Onderhoud'
ELSE 'Productie'
END AS Productie
FROM
dbo.zLookupYearDays
JOIN dbo.tblUrenRegistratieRegel
ON dbo.zLookupYearDays.Yeardate = dbo.tblUrenRegistratieRegel.DatumUrenReg
JOIN dbo.tblMaterieel
ON dbo.tblMaterieel.MaterieelID = dbo.tblUrenRegistratieRegel.HulpstukId2
JOIN dbo.zLookupBedrijven
ON dbo.tblMaterieel.GebruikerBV = dbo.zLookupBedrijven.BedrijfsID
WHERE
dbo.tblMaterieel.Actief = 1
