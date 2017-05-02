/*

Definitie: eigen materieel: materieel dat de werkmaatschappij huurt / least van Sagro Materieel BV

Onderhoud aan eigen materieel (gebruikerBV): kosten rechtstreeks op kostenplaats materieel
Onderhoud andermans materieel: factuur aan andere werkmaatschappij
=======
Projectnummer (eigen werken): Projectnummer
Projectnummer (werk derden): <eigen BV, 2><jaartal, 2><derden BV, 2><Weeknummer, 2>
Projectnummer: 999x direct doorbelasten aan eigen werkmaatschappij
Personeelsnummer: <Divisie, 2> + laatste 7 cijders van het personeelsnummer
Kostendrager: Projectnummer van derden, anders leeg
Grootboekrekening: 5920
Dekkingsrekening: 8998
Omschrijving: omschrijving werkzaamheden

Niet van toepassing
Kostenplaats: materieelstuk
*/


SELECT
	'Onderhoud' AS Type,
	DMY.WeekNo AS Weeknummer,
	DMY.YearDateYear AS Jaar,

	UREN.DatumUrenReg AS DatumUrenReg,
	convert(char(2), BMDW.ProjectCodePrefix) + right(PERS.PersoneelNo,7) AS PersoneelNo,
	PERS.BSN AS BSN,

	CASE
		WHEN PERS.Initialen IS NULL and PERS.Voornaam is NULL THEN ''
		WHEN PERS.Initialen IS NULL THEN left(PERS.Voornaam, 1)
		ELSE PERS.Initialen
	END AS Initialen,

	CASE
		WHEN PERS.Voornaam IS NULL THEN ''
		ELSE PERS.Voornaam
	END AS Voornaam,

	CASE
		WHEN PERS.Tussenvoegsel IS NULL THEN ''
		ELSE PERS.Tussenvoegsel
	END AS Tussenvoegsel,

	PERS.Achternaam AS Achternaam,

	CASE BMAT.ProjectCodePrefix
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN BMDW.ProjectCodePrefix THEN UREN.ProjectNr
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE
			convert(nvarchar(50),
			9900000000 +
			BMDW.[ProjectCodePrefix] * 1000000 +
			RIGHT(datepart(yy, UREN.[DatumUrenReg]),2) * 10000 +
			LEFT(UREN.[ProjectNr], 2) * 100 +
			datepart(ISO_WEEK,UREN.[DatumUrenReg]) * 1
			)
	END AS ProjectNr,

	CASE LEFT(UREN.[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN 'Nee'
		-- Situatie 2: Hoofdaannemer: Projectnummer = Projectnummer, Kostendrager = [null]
		WHEN BMDW.[ProjectCodePrefix] THEN 'Nee'
		-- Situatie 3: Onderaannemer: Projectnummer = [], Kostendrager = Projectnummer
		ELSE 'Ja'
	END AS Factuur,

	BMDW.Bedrijfsnaam AS Crediteur,

	CASE LEFT(UREN.[ProjectNr],2)
	-- Situatie 1: 999*
		WHEN 99 THEN 'Eigen project'
	-- Situatie 2: Hoofdaannemer: Projectnummer = Projectnummer, Kostendrager = [null]
	WHEN BMDW.[ProjectCodePrefix] THEN 'Eigen project'
	-- Situatie 3: Onderaannemer: Projectnummer = [], Kostendrager = Projectnummer
	ELSE
		(
			SELECT
				[dbo].[zLookupBedrijven].[Bedrijfsnaam]
			FROM
				[dbo].[zLookupBedrijven]
			WHERE
				[dbo].[zLookupBedrijven].[ProjectCodePrefix] = LEFT(UREN.[ProjectNr],2)
		)
	END AS Debiteur,

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
	AND right(UREN.ProjectNr,4) IN ('4400','4450','4813')
	AND UREN.Uren <> 0
	AND len(PERS.PersoneelNo) >= 7
	AND datepart(yyyy,UREN.[DatumUrenReg]) >= 2017
