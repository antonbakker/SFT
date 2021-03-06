/*
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

Situatie 1: projectnummer = 999*
In dit geval handelt het om interne uren. Deze kunnen niet worden doorbelast en mogen niet als kosten worden geboekt

Situatie 2: project is van de werkmaatschappij waar de medewerker in dienst is
In dit geval betreft het een eigen project en hoeft er niets te veranderen en is er geen sprake van een kostendrageer

Situatie 3: project is van een andere werkmaatschappij dan waar de medewerker in dienst is
In dit geval wordt er een nieuw projectnummer aangemoaakt op basis van onderstaande regel en wordt het oorspronkelijke projectnummer overgnomen als Kostendrager
Opbouw projectnummer
Werkmaatschappij waar de werknemer voor werkt: 2 posities
Laatste twee cijfers van het jaartal: 2 posities
Werkmaatschappij waarvoor het project wordt uitgevoerd: 2 posities
Weeknummer waarin de uren zijn uitgevoerd: 2 posities
Voorbeeld: 27172105
Werknemer: 27 (De Bokx)
Jaar: 2017
Projecteigenaar: 21 (Aanneming)
Weeknummr: 5

*/


SELECT
	'Personeel' AS Type,
	DMY.WeekNo AS Weeknummer,
	DMY.YearDateYear AS Jaar,


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
		-- Situatie 2: Hoofdaannemer: Projectnummer = Projectnummer, Kostendrager = [null]
		WHEN [dbo].[zLookupBedrijven].[ProjectCodePrefix] THEN [dbo].[tblUrenRegistratieRegel].[ProjectNr]
		-- Situatie 3: Onderaannemer: Projectnummer = [], Kostendrager = Projectnummer
		ELSE
			convert(nvarchar(50),
			9900000000 +
			[dbo].[zLookupBedrijven].[ProjectCodePrefix] * 1000000 +
			RIGHT(datepart(yy, [dbo].[tblUrenRegistratieRegel].[DatumUrenReg]),2) * 10000 +
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

	dbo.tblUrenRegistratieRegel.Werkzaamheden AS Werkzaamheden,
	dbo.tblUrenRegistratieRegel.Uren AS Uren,
	dbo.tblPersoneel.TariefIntern AS TariefIntern,

/* 2017-07-11 Onderstaande Case verwijderd om er voor te zorgen dat kosten van personeel, ongeacht het project wordt doorbelast. */


	/* dbo.tblUrenRegistratieRegel.Uren * dbo.tblPersoneel.TariefIntern AS KostenIntern, */
--	CASE RIGHT([dbo].[tblUrenRegistratieRegel].[ProjectNr],4)
	-- Testen pf er sprake is van een onderhoudsproject
	/* onderstaande controle op specifieke projectnummers zorgt er voor dat de personen worden aangemakt in de betreffende werkmaatschappij */
--		WHEN '4400' THEN 0
--		WHEN '4450' THEN 0
--		WHEN '4813' THEN 0
--		ELSE dbo.tblUrenRegistratieRegel.Uren * dbo.tblPersoneel.TariefIntern
--	END AS KostenIntern,

/* Nieuwe code */
	dbo.tblUrenRegistratieRegel.Uren * dbo.tblPersoneel.TariefIntern AS KostenIntern,

	dbo.zLookupBedrijven.Bedrijfsnaam AS ProjectBV,
	dbo.tblUrenRegistratieRegel.UrenregistratieRegelID AS ID,
	'5915' AS grootboek,
	'1936' AS dekking,

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
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE ''
	END AS Dekkingsrekening,
*/


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
	and left([dbo].[tblUrenRegistratieRegel].[ProjectNr],2) <> [dbo].[zLookupBedrijven].[ProjectCodePrefix]
	and len(dbo.tblPersoneel.PersoneelNo) >= 7
