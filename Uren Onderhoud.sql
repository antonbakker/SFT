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
	AND right(UREN.ProjectNr,4) IN ('4400','4450','4813')
	AND UREN.Uren <> 0
	AND len(PERS.PersoneelNo) >= 7
	AND datepart(yyyy,UREN.[DatumUrenReg]) >= 2017


/* niet overnemen
	and datepart(mm, UREN.[DatumUrenReg]) <= 8
	and PERS.Initialen is NULL */




============================== hieronder oud ================================


























/*
<<<<<<< HEAD

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

Moeten de 999x uren op een aparte grootboekrekening worden geplaatst?

>>>>>>> origin/master
*/


SELECT
	DMY.WeekNo AS Weeknummer,
	DMY.YearDateYear AS Jaar,


<<<<<<< HEAD
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
=======
	dbo.tblUrenRegistratieRegel.DatumUrenReg,
	convert(char(2), [dbo].[zLookupBedrijven].[ProjectCodePrefix]) + right(dbo.tblPersoneel.PersoneelNo,7) AS PersoneelNo,
	dbo.tblPersoneel.BSN AS BSN,

	CASE
		WHEN dbo.tblPersoneel.Initialen IS NULL and dbo.tblPersoneel.Voornaam is NULL THEN ''
		WHEN dbo.tblPersoneel.Initialen IS NULL THEN left(dbo.tblPersoneel.Voornaam, 1)
		ELSE dbo.tblPersoneel.Initialen
	END AS Initialen,

	CASE
		WHEN dbo.tblPersoneel.Voornaam IS NULL THEN ''
		ELSE dbo.tblPersoneel.Voornaam
	END AS Voornaam,

	CASE
		WHEN dbo.tblPersoneel.Tussenvoegsel IS NULL THEN ''
		ELSE dbo.tblPersoneel.Tussenvoegsel
	END AS Tussenvoegsel,


	dbo.tblPersoneel.Achternaam AS Achternaam,


/*	CASE
		WHEN dbo.tblPersoneel.Initialen IS NULL and dbo.tblPersoneel.Voornaam is NULL THEN dbo.tblPersoneel.Achternaam
		WHEN dbo.tblPersoneel.Initialen IS NULL THEN dbo.tblPersoneel.Achternaam + ' ' + left(dbo.tblPersoneel.Voornaam, 1)
		ELSE  dbo.tblPersoneel.Achternaam + ' ' + dbo.tblPersoneel.Initialen
	END AS Naam, */

	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN [dbo].[tblUrenRegistratieRegel].[ProjectNr]
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN [dbo].[tblUrenRegistratieRegel].[ProjectNr]
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE
			convert(nvarchar(50),
			[dbo].[zLookupBedrijven].[ProjectCodePrefix] * 1000000 + RIGHT(
			datepart(yy, [dbo].[tblUrenRegistratieRegel].[DatumUrenReg]),2) * 10000 +
			LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr], 2) * 100 +
			datepart(ISO_WEEK,[dbo].[tblUrenRegistratieRegel].[DatumUrenReg]) * 1
			)
	END AS ProjectNr,

	dbo.tblUrenRegistratieRegel.Werkzaamheden AS Werkzaamheden,
	dbo.tblUrenRegistratieRegel.Uren AS Uren,
	dbo.tblPersoneel.TariefIntern AS TariefIntern,

	CASE RIGHT([dbo].[tblUrenRegistratieRegel].[ProjectNr],4)
	-- Testen pf er sprake is van een onderhoudsproject
		WHEN '4400' THEN 0
		WHEN '4450' THEN 0
		WHEN '4813' THEN 0
		ELSE dbo.tblUrenRegistratieRegel.Uren * dbo.tblPersoneel.TariefIntern
	END AS KostenIntern,

	/*dbo.tblUrenRegistratieRegel.Uren * dbo.tblPersoneel.TariefIntern AS KostenIntern, */
	dbo.zLookupBedrijven.Bedrijfsnaam AS ProjectBV,
	dbo.tblUrenRegistratieRegel.UrenregistratieRegelID AS ID,
	'5910' AS grootboek,
	'8999' AS dekking,

	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN ''
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN 	''
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE [dbo].[tblUrenRegistratieRegel].[ProjectNr]
	END AS kstdr

/*
	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN ''
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN '5910'
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE ''
	END AS Grootboekrekening,

	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN ''
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN '8999'
>>>>>>> origin/master
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE ''
	END AS Dekkingsrekening,
*/


FROM
<<<<<<< HEAD
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
=======
	dbo.tblUrenRegistratieRegel
	JOIN dbo.tblPersoneel ON dbo.tblUrenRegistratieRegel.PersoneelID = dbo.tblPersoneel.PersoneelID
	JOIN dbo.zLookupBedrijven ON dbo.tblPersoneel.WerkgeverBV = dbo.zLookupBedrijven.BedrijfsID
	JOIN dbo.zLookupYearDays AS DMY ON dbo.tblUrenRegistratieRegel.DatumUrenReg = DMY.YearDate

WHERE
	dbo.tblUrenRegistratieRegel.Uren is not null
	/* onderstaande regel niet meenemen, zodat alle uren worden geboekt en dus al het personeel wordt aangemaakt */
	/* and right([dbo].[tblUrenRegistratieRegel].[ProjectNr],4) NOT IN ('4400', '4450', '4813') */
	and dbo.tblUrenRegistratieRegel.Uren <> 0
	and datepart(yyyy, [dbo].[tblUrenRegistratieRegel].[DatumUrenReg]) >= 2017
	and [dbo].[tblUrenRegistratieRegel].[ProjectNr] not like '99%'
	and len(dbo.tblPersoneel.PersoneelNo) >= 7


/* niet overnemen
>>>>>>> origin/master
	and datepart(mm, UREN.[DatumUrenReg]) <= 8
	and PERS.Initialen is NULL */
