/*

Definitie: eigen materieel: materieel dat de werkmaatschappij huurt / least van Sagro Materieel BV

Onderhoud aan eigen materieel (gebruikerBV): kosten rechtstreeks op kostenplaats materieel
Onderhoud andermans materieel: factuur aan andere werkmaatschappij
*/


SELECT
	DMY.WeekNo AS Weeknummer,
	DMY.YearDateYear AS Jaar,


	UREN.DatumUrenReg AS DatumUrenReg,
	convert(char(2), BMDW.ProjectCodePrefix) + right(PERS.PersoneelNo,7) AS PersoneelNo,
	PERS.BSN AS BSN,
	CASE
		WHEN PERS.Initialen IS NULL and PERS.Voornaam is NULL THEN PERS.Achternaam
		WHEN PERS.Initialen IS NULL THEN PERS.Achternaam + ' ' + left(PERS.Voornaam, 1)
		ELSE  PERS.Achternaam + ' ' + PERS.Initialen
	END AS Naam,

	CASE BMAT.ProjectCodePrefix
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN BMDW.ProjectCodePrefix THEN UREN.ProjectNr
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE
			convert(nvarchar(50),
			BMDW.[ProjectCodePrefix] * 1000000 +
			RIGHT(datepart(yy, UREN.[DatumUrenReg]),2) * 10000 + 
			LEFT(UREN.[ProjectNr], 2) * 100 + 
			datepart(ISO_WEEK,UREN.[DatumUrenReg]) * 1
			)
	END AS ProjectNr,

	CASE BMDW.ProjectCodePrefix
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN BMAT.ProjectCodePrefix THEN MAT.KostenPlaats
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE ''
	END AS KostenplaatsMaterieel,

	UREN.Werkzaamheden AS Werkzaamheden,
	UREN.Uren AS Uren,
	PERS.TariefIntern AS TariefIntern,
	UREN.Uren * PERS.TariefIntern AS KostenIntern,
	BMDW.Bedrijfsnaam AS ProjectBV,
	BMAT.Bedrijfsnaam AS MaterieelGebruikerBV,
	UREN.Opmerking AS Opmerking,
	UREN.UrenregistratieRegelID AS ID,

	CASE BMDW.ProjectCodePrefix
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN BMAT.ProjectCodePrefix THEN right(UREN.ProjectNr, 4)
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE '5910'
	END AS grootboek,

	'8997' AS dekking,

	CASE BMDW.ProjectCodePrefix
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN BMAT.ProjectCodePrefix THEN ''
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE UREN.[ProjectNr]
	END AS kstdr






/*
	CASE BMDW.ProjectCodePrefix
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN BMAT.ProjectCodePrefix THEN '8997'
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE ''
	END AS Dekkingsrekening,
*/


FROM
	dbo.tblUrenRegistratieRegel AS UREN
	JOIN dbo.tblPersoneel PERS ON UREN.PersoneelID = PERS.PersoneelID 
	JOIN dbo.tblMaterieel MAT ON UREN.MaterieelID = MAT.MaterieelID 
	JOIN dbo.zLookupBedrijven AS BMDW ON PERS.WerkgeverBV = BMDW.BedrijfsID 
	JOIN dbo.zLookupBedrijven AS BMAT ON MAT.GebruikerBV = BMAT.BedrijfsID
	JOIN dbo.zLookupYearDays AS DMY ON UREN.DatumUrenReg = DMY.YearDate


WHERE
	UREN.Uren is not null
	and right(UREN.ProjectNr,4) IN ('4400','4450','4813')
	and UREN.Uren <> 0
	and len(PERS.PersoneelNo) >= 7

	and datepart(yyyy,UREN.[DatumUrenReg]) >= 2017


/* niet overnemen 
	and datepart(mm, UREN.[DatumUrenReg]) <= 8
	and PERS.Initialen is NULL */
