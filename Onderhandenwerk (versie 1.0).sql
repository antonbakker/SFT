
/* Personeel */

SELECT
	'Personeel' AS Type,
	DMY.WeekNo AS Weeknummer,
	DMY.YearDateYear AS Jaar,

/*
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
*/

	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN [dbo].[tblUrenRegistratieRegel].[ProjectNr]
		-- Situatie 2: Hoofdaannemer: Projectnummer = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN [dbo].[tblUrenRegistratieRegel].[ProjectNr]
		-- Situatie 3: Onderaannemer: Projectnummer = [], Kostendrager = Projectnummer
		ELSE
			convert(nvarchar(50),
			[dbo].[zLookupBedrijven].[ProjectCodePrefix] * 1000000 + RIGHT(
			datepart(yy, [dbo].[tblUrenRegistratieRegel].[DatumUrenReg]),2) * 10000 +
			LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr], 2) * 100 +
			datepart(ISO_WEEK,[dbo].[tblUrenRegistratieRegel].[DatumUrenReg]) * 1
			)
	END AS ProjectNr,

	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN 'Nee'
		-- Situatie 2: Hoofdaannemer: Projectnummer = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN 'Nee'
		-- Situatie 3: Onderaannemer: Projectnummer = [], Kostendrager = Projectnummer
		ELSE 'Ja'
	END AS Factuur,

	[dbo].[zLookupBedrijven].Bedrijfsnaam AS Crediteur,

	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN 'Eigen project'
		-- Situatie 2: Hoofdaannemer: Projectnummer = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN 'Eigen project'
		-- Situatie 3: Onderaannemer: Projectnummer = [], Kostendrager = Projectnummer
		ELSE
			(
				SELECT
					[dbo].[zLookupBedrijven].[Bedrijfsnaam]
				FROM
					[dbo].[zLookupBedrijven]
				WHERE
					[dbo].[zLookupBedrijven].[ProjectCodePrefix] = LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
			)
	END AS Debiteur,

/*
	dbo.tblUrenRegistratieRegel.Werkzaamheden AS Werkzaamheden,
	dbo.tblUrenRegistratieRegel.Uren AS Uren,
	dbo.tblPersoneel.TariefIntern AS TariefIntern,
*/

	/* dbo.tblUrenRegistratieRegel.Uren * dbo.tblPersoneel.TariefIntern AS KostenIntern, */
	CASE RIGHT([dbo].[tblUrenRegistratieRegel].[ProjectNr],4)
	-- Testen pf er sprake is van een onderhoudsproject
	/* onderstaande controle op specifieke projectnummers zorgt er voor dat de personen worden aangemakt in de betreffende werkmaatschappij */
		WHEN '4400' THEN 0
		WHEN '4450' THEN 0
		WHEN '4813' THEN 0
		ELSE dbo.tblUrenRegistratieRegel.Uren * dbo.tblPersoneel.TariefIntern
	END AS KostenIntern,

'0000' AS Kostenplaats,

/*
	dbo.zLookupBedrijven.Bedrijfsnaam AS ProjectBV,
	dbo.tblUrenRegistratieRegel.UrenregistratieRegelID AS ID,
*/

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

FROM
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

/* Union */

UNION ALL

/* Materieel */

SELECT
	'Materieel' AS Type,
	DMY.WeekNo AS Weeknummer,
	DMY.YearDateYear AS Jaar,

/*
	dbo.tblUrenRegistratieRegel.DatumUrenReg AS DatumUrenReg,
*/

	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
 		-- Situatie 1: 999*
		WHEN 99 THEN [dbo].[tblUrenRegistratieRegel].[ProjectNr]
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN [dbo].[tblUrenRegistratieRegel].[ProjectNr]
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
			/*WHEN left([dbo].[tblUrenRegistratieRegel].[ProjectNr],2) <> [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN 'test' */
		ELSE
			convert(nvarchar(50),
			[dbo].[zLookupBedrijven].[ProjectCodePrefix] * 1000000 +
			RIGHT(datepart(yy, [dbo].[tblUrenRegistratieRegel].[DatumUrenReg]),2) * 10000 +
			LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2) * 100 +
			datepart(ISO_WEEK, [dbo].[tblUrenRegistratieRegel].[DatumUrenReg]) * 1
			)
	END AS ProjectNr,

	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN 'Nee'
		-- Situatie 2: Hoofdaannemer: Projectnummer = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN 'Nee'
		-- Situatie 3: Onderaannemer: Projectnummer = [], Kostendrager = Projectnummer
		ELSE 'Ja'
	END AS Factuur,

	[dbo].[zLookupBedrijven].Bedrijfsnaam AS Crediteur,

	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN 'Eigen project'
		-- Situatie 2: Hoofdaannemer: Projectnummer = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN 'Eigen project'
		-- Situatie 3: Onderaannemer: Projectnummer = [], Kostendrager = Projectnummer
		ELSE
			(
				SELECT
					[dbo].[zLookupBedrijven].[Bedrijfsnaam]
				FROM
					[dbo].[zLookupBedrijven]
				WHERE
					[dbo].[zLookupBedrijven].[ProjectCodePrefix] = LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
			)
	END AS Debiteur,

/*
	dbo.tblUrenRegistratieRegel.Werkzaamheden AS Werkzaamheden,
*/


/*
	dbo.tblMaterieel.KostenPlaats + ' - ' + dbo.tblMaterieel.Omschrijving AS Omschrijving,
	dbo.tblUrenRegistratieRegel.Uren,
	dbo.tblMaterieel.TariefIntern AS TariefIntern,
	dbo.tblUrenRegistratieRegel.Opmerking AS Opmerking,
*/

	dbo.tblUrenRegistratieRegel.Uren * dbo.tblMaterieel.TariefIntern AS KostenIntern,
	dbo.tblMaterieel.KostenPlaats AS Kostenplaats,

/*
	dbo.zLookupBedrijven.Bedrijfsnaam AS ProjectBV,
	dbo.tblUrenRegistratieRegel.UrenregistratieRegelID AS ID,
*/

	'5920' AS grootboek,
	'8998' AS dekking,

	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN ''
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN ''
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE [dbo].[tblUrenRegistratieRegel].[ProjectNr]
	END AS kstdr

/*
	'Materieel' AS Regeltype
*/

FROM
	dbo.tblUrenRegistratieRegel
	JOIN dbo.tblMaterieel ON dbo.tblUrenRegistratieRegel.MaterieelID = dbo.tblMaterieel.MaterieelID
	JOIN dbo.zLookupBedrijven ON dbo.tblMaterieel.GebruikerBV = dbo.zLookupBedrijven.BedrijfsID
	JOIN dbo.zLookupYearDays AS DMY ON dbo.tblUrenRegistratieRegel.DatumUrenReg = DMY.YearDate

WHERE
	dbo.tblUrenRegistratieRegel.Uren is not null
	and [dbo].[tblUrenRegistratieRegel].[ProjectNr] not like '99%'
	and right([dbo].[tblUrenRegistratieRegel].[ProjectNr],4) NOT IN ('4400', '4450', '4813')
	and dbo.tblUrenRegistratieRegel.Uren <> 0
	and datepart(yyyy,[dbo].[tblUrenRegistratieRegel].[DatumUrenReg]) >= 2017

UNION ALL

SELECT
	'Materieel' AS Type,
	DMY.WeekNo AS Weeknummer,
	DMY.YearDateYear AS Jaar,

/*
	dbo.tblUrenRegistratieRegel.DatumUrenReg AS DatumUrenReg,
*/

	CASE LEFT(
		[dbo].[tblUrenRegistratieRegel].[ProjectNr],
		2
		) -- Situatie 1: 999*
		WHEN 99 THEN [dbo].[tblUrenRegistratieRegel].[ProjectNr]
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN [dbo].[tblUrenRegistratieRegel].[ProjectNr]
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
			/*WHEN left([dbo].[tblUrenRegistratieRegel].[ProjectNr],2) <> [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN 'test' */
		ELSE
			convert(nvarchar(50),
			[dbo].[zLookupBedrijven].[ProjectCodePrefix] * 1000000 +
			RIGHT(datepart(yy, [dbo].[tblUrenRegistratieRegel].[DatumUrenReg]),2) * 10000 +
			LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2) * 100 +
			datepart(ISO_WEEK, [dbo].[tblUrenRegistratieRegel].[DatumUrenReg]) * 1
			)
	END AS ProjectNr,

	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN 'Nee'
		-- Situatie 2: Hoofdaannemer: Projectnummer = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN 'Nee'
		-- Situatie 3: Onderaannemer: Projectnummer = [], Kostendrager = Projectnummer
		ELSE 'Ja'
	END AS Factuur,

	[dbo].[zLookupBedrijven].Bedrijfsnaam AS Crediteur,

	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN 'Eigen project'
		-- Situatie 2: Hoofdaannemer: Projectnummer = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN 'Eigen project'
		-- Situatie 3: Onderaannemer: Projectnummer = [], Kostendrager = Projectnummer
		ELSE
			(
				SELECT
					[dbo].[zLookupBedrijven].[Bedrijfsnaam]
				FROM
					[dbo].[zLookupBedrijven]
				WHERE
					[dbo].[zLookupBedrijven].[ProjectCodePrefix] = LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
			)
	END AS Debiteur,

/*
	dbo.tblUrenRegistratieRegel.Werkzaamheden AS Werkzaamheden,
*/


/*
	dbo.tblMaterieel.KostenPlaats + ' - ' + dbo.tblMaterieel.Omschrijving AS Omschrijving,
	dbo.tblUrenRegistratieRegel.Uren,
	dbo.tblMaterieel.TariefIntern AS TariefIntern,
	dbo.tblUrenRegistratieRegel.Opmerking AS Opmerking,

*/
	dbo.tblUrenRegistratieRegel.Uren * dbo.tblMaterieel.TariefIntern AS KostenIntern,
	dbo.tblMaterieel.KostenPlaats AS KostenPlaats,

/*
	dbo.zLookupBedrijven.Bedrijfsnaam AS ProjectBV,
	dbo.tblUrenRegistratieRegel.UrenregistratieRegelID AS ID,
*/

	'5920' AS grootboek,
	'8998' AS dekking,

	CASE LEFT(
		[dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN ''
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN ''
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE [dbo].[tblUrenRegistratieRegel].[ProjectNr]
	END AS kstdr

/*
	'Hulpstuk1' AS Regeltype
*/

FROM
	dbo.tblUrenRegistratieRegel
	JOIN dbo.tblMaterieel ON dbo.tblUrenRegistratieRegel.HulpstukId = dbo.tblMaterieel.MaterieelID
	JOIN dbo.zLookupBedrijven ON dbo.tblMaterieel.GebruikerBV = dbo.zLookupBedrijven.BedrijfsID
	JOIN dbo.zLookupYearDays AS DMY ON dbo.tblUrenRegistratieRegel.DatumUrenReg = DMY.YearDate

WHERE
	dbo.tblUrenRegistratieRegel.Uren is not null
	and right([dbo].[tblUrenRegistratieRegel].[ProjectNr],4) NOT IN ('4400', '4450', '4813')
	and dbo.tblUrenRegistratieRegel.Uren <> 0
	and datepart(yyyy,[dbo].[tblUrenRegistratieRegel].[DatumUrenReg]) >= 2017
	and [dbo].[tblUrenRegistratieRegel].[ProjectNr] not like '99%'


UNION ALL

SELECT
	'Materieel' AS Type,
	DMY.WeekNo AS Weeknummer,
	DMY.YearDateYear AS Jaar,

/*
	dbo.tblUrenRegistratieRegel.DatumUrenReg AS DatumUrenReg,
*/

	CASE LEFT(
		[dbo].[tblUrenRegistratieRegel].[ProjectNr],
		2
		) -- Situatie 1: 999*
		WHEN 99 THEN [dbo].[tblUrenRegistratieRegel].[ProjectNr]
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN [dbo].[tblUrenRegistratieRegel].[ProjectNr]
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
			/*WHEN left([dbo].[tblUrenRegistratieRegel].[ProjectNr],2) <> [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN 'test' */
		ELSE
			convert(nvarchar(50),
			[dbo].[zLookupBedrijven].[ProjectCodePrefix] * 1000000 +
			RIGHT(datepart(yy, [dbo].[tblUrenRegistratieRegel].[DatumUrenReg]),2) * 10000 +
			LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2) * 100 +
			datepart(ISO_WEEK, [dbo].[tblUrenRegistratieRegel].[DatumUrenReg]) * 1
			)
	END AS ProjectNr,

	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN 'Nee'
		-- Situatie 2: Hoofdaannemer: Projectnummer = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN 'Nee'
		-- Situatie 3: Onderaannemer: Projectnummer = [], Kostendrager = Projectnummer
		ELSE 'Ja'
	END AS Factuur,

	[dbo].[zLookupBedrijven].Bedrijfsnaam AS Crediteur,

	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN 'Eigen project'
		-- Situatie 2: Hoofdaannemer: Projectnummer = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN 'Eigen project'
		-- Situatie 3: Onderaannemer: Projectnummer = [], Kostendrager = Projectnummer
		ELSE
			(
				SELECT
					[dbo].[zLookupBedrijven].[Bedrijfsnaam]
				FROM
					[dbo].[zLookupBedrijven]
				WHERE
					[dbo].[zLookupBedrijven].[ProjectCodePrefix] = LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
			)
	END AS Debiteur,

/*
	dbo.tblUrenRegistratieRegel.Werkzaamheden AS Werkzaamheden,
*/


/*
	dbo.tblMaterieel.KostenPlaats + ' - ' + dbo.tblMaterieel.Omschrijving AS Omschrijving,
	dbo.tblUrenRegistratieRegel.Uren,
	dbo.tblMaterieel.TariefIntern AS TariefIntern,
	dbo.tblUrenRegistratieRegel.Opmerking AS Opmerking,
*/

	dbo.tblUrenRegistratieRegel.Uren * dbo.tblMaterieel.TariefIntern AS KostenIntern,
	dbo.tblMaterieel.KostenPlaats AS Kostenplaats,

/*
	dbo.zLookupBedrijven.Bedrijfsnaam AS ProjectBV,
	dbo.tblUrenRegistratieRegel.UrenregistratieRegelID AS ID,
*/

	'5920' AS grootboek,
	'8998' AS dekking,

	CASE LEFT(
		[dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN ''
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN ''
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE [dbo].[tblUrenRegistratieRegel].[ProjectNr]
	END AS kstdr

/*
	'Hulpstuk2' AS Regeltype
*/

FROM
	dbo.tblUrenRegistratieRegel
	JOIN dbo.tblMaterieel ON dbo.tblUrenRegistratieRegel.HulpstukId2 = dbo.tblMaterieel.MaterieelID
	JOIN dbo.zLookupBedrijven ON dbo.tblMaterieel.GebruikerBV = dbo.zLookupBedrijven.BedrijfsID
	JOIN dbo.zLookupYearDays AS DMY ON dbo.tblUrenRegistratieRegel.DatumUrenReg = DMY.YearDate

WHERE
	dbo.tblUrenRegistratieRegel.Uren is not null
	and right([dbo].[tblUrenRegistratieRegel].[ProjectNr],4) NOT IN ('4400', '4450', '4813')
	and dbo.tblUrenRegistratieRegel.Uren <> 0
	and datepart(yyyy,[dbo].[tblUrenRegistratieRegel].[DatumUrenReg]) >= 2017
	and [dbo].[tblUrenRegistratieRegel].[ProjectNr] not like '99%'

/* Union */

UNION ALL

/* Onderhoud */

SELECT
	'Onderhoud' AS Type,
	DMY.WeekNo AS Weeknummer,
	DMY.YearDateYear AS Jaar,

/*
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
*/

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

/*
	CASE BMDW.ProjectCodePrefix
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN BMAT.ProjectCodePrefix THEN MAT.KostenPlaats
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE ''
	END AS KostenplaatsMaterieel,
*/


/*
	UREN.Werkzaamheden AS Werkzaamheden,
	UREN.Uren AS Uren,
	PERS.TariefIntern AS TariefIntern,
*/

	UREN.Uren * PERS.TariefIntern AS KostenIntern,
	CASE BMDW.ProjectCodePrefix
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN BMAT.ProjectCodePrefix THEN MAT.KostenPlaats
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE ''
	END AS Kostenplaats,

/*
	BMDW.Bedrijfsnaam AS ProjectBV,
	BMAT.Bedrijfsnaam AS MaterieelGebruikerBV,
	UREN.Opmerking AS Opmerking,
	UREN.UrenregistratieRegelID AS ID,
*/

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
