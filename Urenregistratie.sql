SELECT
dbo.zLookupYearDays.Yeardate,
dbo.zLookupYearDays.WeekNo,
dbo.zLookupYearDays.WeekdayNo,
dbo.zLookupYearDays.YeardateYear,
dbo.zLookupYearDays.YeardateMonth,

dbo.zLookupBedrijven.Bedrijfsnaam AS Werkmaatschappij,

PERS.PersoneelNo,PERS.CAO,
PERS.Actief AS PERSActief, 
PERS.TariefIntern AS PersTarief,
PERS.VolledigeNaam,
PERS.Beroep,
PERS.TariefIntern * dbo.tblUrenRegistratieRegel.Uren AS PERSKosten,

dbo.tblUrenRegistratieRegel.ProjectNr,
dbo.tblUrenRegistratieRegel.Werkzaamheden,
dbo.tblUrenRegistratieRegel.Uren,
dbo.tblUrenRegistratieRegel.Opmerking,


-- GBR.Bedrijfsnaam AS [Gebruiker],


MAT.KostenPlaats AS MATkstpl,
MAT.Groep AS MATgrp,
MAT.Omschrijving AS MATomschr,
MAT.Kenteken AS MATkenteken,
MAT.Actief AS [MATActief],
MAT.GewichtTarra AS MATtarra,
MAT.Laadvermogen AS MATlaad,
MAT.TariefIntern AS MATTarief,
MAT.TariefIntern * dbo.tblUrenRegistratieRegel.Uren AS MATIntereKosten,
MAT.Verbruik,


HSTK1.KostenPlaats AS HSTK1kstpl,
HSTK1.Groep AS HSTK1grp,
HSTK1.Omschrijving AS HSTK1omschr,
HSTK1.Kenteken AS HSTK1kenteken,
HSTK1.Actief AS [HSTK1Actief],
HSTK1.TariefIntern AS HSTK1Tarief,
HSTK1.TariefIntern * dbo.tblUrenRegistratieRegel.Uren AS HSTK1IntereKosten,


HSTK2.KostenPlaats AS HSTK2kstpl,
HSTK2.Groep AS HSTK2grp,
HSTK2.Omschrijving AS HSTK2omschr,
HSTK2.Kenteken AS HSTK2kenteken,
HSTK2.Actief AS [HSTK2Actief],
HSTK2.TariefIntern AS HSTK2Tarief,
HSTK2.TariefIntern * dbo.tblUrenRegistratieRegel.Uren AS HSTK2IntereKosten



FROM
dbo.tblPersoneel AS PERS
JOIN dbo.tblUrenRegistratieRegel ON PERS.PersoneelID = dbo.tblUrenRegistratieRegel.PersoneelID 
LEFT JOIN dbo.tblMaterieel AS MAT ON dbo.tblUrenRegistratieRegel.MaterieelID = MAT.MaterieelID 
LEFT JOIN dbo.tblMaterieel AS HSTK1 ON dbo.tblUrenRegistratieRegel.Hulpstukid = HSTK1.MaterieelID 
LEFT JOIN dbo.tblMaterieel AS HSTK2 ON dbo.tblUrenRegistratieRegel.Hulpstukid2 = HSTK2.MaterieelID 
JOIN dbo.zLookupYearDays ON dbo.zLookupYearDays.Yeardate = dbo.tblUrenRegistratieRegel.DatumUrenReg 
JOIN dbo.zLookupBedrijven ON dbo.zLookupBedrijven.BedrijfsID = PERS.WerkgeverBV 
-- JOIN dbo.zLookupBedrijven AS [GBR] ON [MAT].BedrijfsID = dbo.tblMaterieel.GebruikerBV
WHERE
-- dbo.zLookupYearDays.YeardateYear = 2017
dbo.tblUrenRegistratieRegel.ProjectNr = '21173002'
