SELECT
    dbo.zLookupAlgemeen.Waarde,
    dbo.zLookupBedrijven.Bedrijfsnaam,
    dbo.tblPersoneel.CAO,
    dbo.tblPersoneel.Beroep,
    dbo.tblPersoneel.PersoneelNo,
    dbo.tblPersoneel.VolledigeNaam,
    dbo.tblPersoneel.TariefIntern
FROM
    dbo.tblPersoneel
JOIN dbo.zLookupAlgemeen ON dbo.tblPersoneel.PersoneelType = dbo.zLookupAlgemeen.ID 
JOIN dbo.zLookupBedrijven ON dbo.tblPersoneel.WerkgeverBV = dbo.zLookupBedrijven.BedrijfsID
WHERE
    dbo.tblPersoneel.Actief = 1
    and dbo.zLookupAlgemeen.ID = 51
ORDER BY
    dbo.zLookupBedrijven.Bedrijfsnaam ASC,
    dbo.tblPersoneel.Beroep ASC