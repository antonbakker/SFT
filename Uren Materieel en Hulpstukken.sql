/*
Projectnummer (eigen werken): Projectnummer
Projectnummer (werk derden): <eigen BV, 2><jaartal, 2><derden BV, 2><Weeknummer, 2>
Projectnummer: 999x direct doorbelasten aan eigen werkmaatschappij
Kostendrager: Projectnummer van derden, anders leeg
Kostenplaats: materieelstuk
Grootboekrekening: 5920
Dekkingsrekening: 8998
Omschrijving: omschrijving materieelstuk / hulpstuk

Niet van toepassing
Personeelsnummer: <Divisie, 2> + laatste 7 cijders van het personeelsnummer

Moeten de 999x uren op een aparte grootboekrekening worden geplaatst?

*/

SELECT
	DMY.YearDateYear AS Jaar,
	DMY.WeekNo AS Weeknummer,

	dbo.tblUrenRegistratieRegel.DatumUrenReg AS DatumUrenReg,

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

	dbo.tblUrenRegistratieRegel.Werkzaamheden AS Werkzaamheden,
	dbo.tblMaterieel.KostenPlaats,
	dbo.tblMaterieel.KostenPlaats + ' - ' + dbo.tblMaterieel.Omschrijving AS Omschrijving,
	dbo.tblUrenRegistratieRegel.Uren,
	dbo.tblMaterieel.TariefIntern AS TariefIntern,
	dbo.tblUrenRegistratieRegel.Opmerking AS Opmerking,
	dbo.tblUrenRegistratieRegel.Uren * dbo.tblMaterieel.TariefIntern AS KostenIntern,
	dbo.zLookupBedrijven.Bedrijfsnaam AS ProjectBV,
	dbo.tblUrenRegistratieRegel.UrenregistratieRegelID AS ID,
	'5920' AS grootboek,
	'8998' AS dekking,

	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN ''
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN ''
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE [dbo].[tblUrenRegistratieRegel].[ProjectNr]
	END AS kstdr,

	'Materieel' AS Regeltype

/*
	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN ''
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN 	'5920'
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE ''
	END AS Grootboekrekening,

	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN ''
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN 	'8999'
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE ''
	END AS Dekkingsrekening,
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


	DMY.YearDateYear AS Jaar,
	DMY.WeekNo AS Weeknummer,

	dbo.tblUrenRegistratieRegel.DatumUrenReg AS DatumUrenReg,

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

	dbo.tblUrenRegistratieRegel.Werkzaamheden AS Werkzaamheden,
	dbo.tblMaterieel.KostenPlaats,
	dbo.tblMaterieel.KostenPlaats + ' - ' + dbo.tblMaterieel.Omschrijving AS Omschrijving,
	dbo.tblUrenRegistratieRegel.Uren,
	dbo.tblMaterieel.TariefIntern AS TariefIntern,
	dbo.tblUrenRegistratieRegel.Opmerking AS Opmerking,
	dbo.tblUrenRegistratieRegel.Uren * dbo.tblMaterieel.TariefIntern AS KostenIntern,
	dbo.zLookupBedrijven.Bedrijfsnaam AS ProjectBV,
	dbo.tblUrenRegistratieRegel.UrenregistratieRegelID AS ID,
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
	END AS kstdr,

	'Hulpstuk1' AS Regeltype

/*
	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN ''
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN 	'5920'
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE ''
	END AS Grootboekrekening,

	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN ''
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN 	'8999'
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE ''
	END AS Dekkingsrekening,
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

	DMY.YearDateYear AS Jaar,
	DMY.WeekNo AS Weeknummer,

	dbo.tblUrenRegistratieRegel.DatumUrenReg AS DatumUrenReg,

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

	dbo.tblUrenRegistratieRegel.Werkzaamheden AS Werkzaamheden,
	dbo.tblMaterieel.KostenPlaats,
	dbo.tblMaterieel.KostenPlaats + ' - ' + dbo.tblMaterieel.Omschrijving AS Omschrijving,
	dbo.tblUrenRegistratieRegel.Uren,
	dbo.tblMaterieel.TariefIntern AS TariefIntern,
	dbo.tblUrenRegistratieRegel.Opmerking AS Opmerking,
	dbo.tblUrenRegistratieRegel.Uren * dbo.tblMaterieel.TariefIntern AS KostenIntern,
	dbo.zLookupBedrijven.Bedrijfsnaam AS ProjectBV,
	dbo.tblUrenRegistratieRegel.UrenregistratieRegelID AS ID,
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
	END AS kstdr,

	'Hulpstuk2' AS Regeltype

/*
	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN ''
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN 	'5920'
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE ''
	END AS Grootboekrekening,

	CASE LEFT([dbo].[tblUrenRegistratieRegel].[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN ''
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN 	'8999'
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE ''
	END AS Dekkingsrekening,
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
