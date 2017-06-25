SELECT
	'Personeel' AS Type,
	DMY.WeekNo AS Weeknummer,
	DMY.YearDateYear AS Jaar,


	SUR.DatumUrenReg,
	convert(char(2), SzB.[ProjectCodePrefix]) + right(SP.PersoneelNo,7) AS PersoneelNo,
	SP.BSN AS BSN,

	CASE
		WHEN SP.Initialen IS NULL and SP.Voornaam is NULL THEN ''
		WHEN SP.Initialen IS NULL THEN left(SP.Voornaam, 1)
		ELSE SP.Initialen
	END AS Initialen,

	CASE
		WHEN SP.Voornaam IS NULL THEN ''
		ELSE SP.Voornaam
	END AS Voornaam,

	CASE
		WHEN SP.Tussenvoegsel IS NULL THEN ''
		ELSE SP.Tussenvoegsel
	END AS Tussenvoegsel,


	SP.Achternaam AS Achternaam,


	CASE LEFT(SUR.[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN SUR.[ProjectNr]
		-- Situatie 2: Hoofdaannemer: Projectnummer = Projectnummer, Kostendrager = [null]
		WHEN SzB.[ProjectCodePrefix] THEN SUR.[ProjectNr]
		-- Situatie 3: Onderaannemer: Projectnummer = [], Kostendrager = Projectnummer
		ELSE
			convert(nvarchar(50),
			9900000000 +
			SzB.[ProjectCodePrefix] * 1000000 +
			RIGHT(datepart(yy, SUR.[DatumUrenReg]),2) * 10000 +
			LEFT(SUR.[ProjectNr], 2) * 100 +
			datepart(ISO_WEEK,SUR.[DatumUrenReg]) * 1
			)
	END AS ProjectNr,

	CASE LEFT(SUR.[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN 'Nee'
		-- Situatie 2: Hoofdaannemer: Projectnummer = Projectnummer, Kostendrager = [null]
		WHEN SzB.[ProjectCodePrefix] THEN 'Nee'
		-- Situatie 3: Onderaannemer: Projectnummer = [], Kostendrager = Projectnummer
		ELSE 'Ja'
	END AS Factuur,

	SzB.Bedrijfsnaam AS Crediteur,

	CASE LEFT(SUR.[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN 'Eigen project'
		-- Situatie 2: Hoofdaannemer: Projectnummer = Projectnummer, Kostendrager = [null]
		WHEN SzB.[ProjectCodePrefix] THEN 'Eigen project'
		-- Situatie 3: Onderaannemer: Projectnummer = [], Kostendrager = Projectnummer
		ELSE
			(
				SELECT
					SSzB.[Bedrijfsnaam]
				FROM
					[BB-SERVER\SQLEXPRESS].[Sagro_backend].[dbo].[zLookupBedrijven] AS SSzB
				WHERE
					SSzB.[ProjectCodePrefix] = LEFT(SUR.[ProjectNr],2)
			)
	END AS Debiteur,

	SUR.Werkzaamheden AS Werkzaamheden,
	SUR.Uren AS Uren,
	SP.TariefIntern AS TariefIntern,

	/* dbo.tblUrenRegistratieRegel.Uren * SP.TariefIntern AS KostenIntern, */
	CASE RIGHT(SUR.[ProjectNr],4)
	-- Testen pf er sprake is van een onderhoudsproject
	/* onderstaande controle op specifieke projectnummers zorgt er voor dat de personen worden aangemakt in de betreffende werkmaatschappij */
		WHEN '4400' THEN 0
		WHEN '4450' THEN 0
		WHEN '4813' THEN 0
		ELSE SUR.Uren * SP.TariefIntern
	END AS KostenIntern,

	SzB.Bedrijfsnaam AS ProjectBV,
	SUR.UrenregistratieRegelID AS ID,
	'5910' AS grootboek,
	'8999' AS dekking,

	CASE LEFT(SUR.[ProjectNr],2)
		-- Situatie 1: 999*
		WHEN 99 THEN ''
		-- Situatie 2: Hoofdaannemer: Projectnummer2 = Projectnummer, Kostendrager = [null]
		WHEN SzB.[ProjectCodePrefix] THEN 	''
		-- Situatie 3: Onderaannemer: Projectnummer2 = [], Kostendrager = Projectnummer
		ELSE SUR.[ProjectNr]
	END AS kstdr


FROM
	 [BB-SERVER\SQLEXPRESS].[Sagro_backend].[dbo].tblUrenRegistratieRegel AS SUR
	JOIN  [BB-SERVER\SQLEXPRESS].[Sagro_backend].[dbo].tblPersoneel AS SP ON SUR.PersoneelID = SP.PersoneelID
	JOIN  [BB-SERVER\SQLEXPRESS].[Sagro_backend].[dbo].zLookupBedrijven AS SzB ON SP.WerkgeverBV = SzB.BedrijfsID
	JOIN  [BB-SERVER\SQLEXPRESS].[Sagro_backend].[dbo].zLookupYearDays AS DMY ON SUR.DatumUrenReg = DMY.YearDate
--    RIGHT JOIN (
    LEFT JOIN (

/* =============== Controle tabel Sagrosoft - Exact Globe ====================== */
-- set transaction isolation level read uncommitted

SELECT
    SzB.Bedrijfsnaam,
    SP.PersoneelNo,
    SP.VolledigeNaam,
    SzD.YeardateYear,
    SzD.WeekNo,
    SUR.DatumUrenReg,
    SUR.Uren,
    SO.Werknummer,
    SO.OpdrachtOmschrijving,
    SUR.UrenregistratieRegelID,
    alleurenids.Division,
    alleurenids.freefield5,
    alleurenids.aantal,
    alleurenids.project,
    alleurenids.reknr,
    alleurenids.dagbknr,
    alleurenids.oms25,
    alleurenids.bdr_hfl,
    alleurenids.debnr,
    alleurenids.crdnr,
    alleurenids.kstplcode,
    alleurenids.kstdrcode,
    alleurenids.freefield1,
    alleurenids.freefield2,
    alleurenids.freefield3,
    alleurenids.freefield4
FROM
    [BB-SERVER\SQLEXPRESS].[Sagro_backend].[dbo].tblUrenRegistratieRegel AS SUR
    JOIN [BB-SERVER\SQLEXPRESS].[Sagro_backend].[dbo].tblPersoneel AS SP
    ON SUR.PersoneelID = SP.PersoneelID 
    JOIN [BB-SERVER\SQLEXPRESS].[Sagro_backend].[dbo].zLookupBedrijven AS SzB
    ON SzB.BedrijfsID = SP.WerkgeverBV 
    LEFT JOIN [BB-SERVER\SQLEXPRESS].[Sagro_backend].[dbo].tblMaterieel AS SM
    ON SUR.MaterieelID = SM.MaterieelID 
    JOIN [BB-SERVER\SQLEXPRESS].[Sagro_backend].[dbo].zLookupYearDays AS SzD
    ON SzD.Yeardate = SUR.DatumUrenReg 
    LEFT JOIN [BB-SERVER\SQLEXPRESS].[Sagro_backend].[dbo].tblOpdracht AS SO
    ON SO.Werknummer = SUR.ProjectNr
    LEFT JOIN 
    (
    SELECT
      Division,
      freefield5,
      aantal,
      project,
      reknr,
      dagbknr,
      oms25,
      bdr_hfl,
      debnr,
      crdnr,
      kstplcode,
      kstdrcode,
      freefield1,
      freefield2,
      freefield3,
      freefield4
    FROM
      [521].dbo.gbkmut
    where
      freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
      Division,
      freefield5,
      aantal,
      project,
      reknr,
      dagbknr,
      oms25,
      bdr_hfl,
      debnr,
      crdnr,
      kstplcode,
      kstdrcode,
      freefield1,
      freefield2,
      freefield3,
      freefield4
    FROM
      [522].dbo.gbkmut
    where
      freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
      Division,
      freefield5,
      aantal,
      project,
      reknr,
      dagbknr,
      oms25,
      bdr_hfl,
      debnr,
      crdnr,
      kstplcode,
      kstdrcode,
      freefield1,
      freefield2,
      freefield3,
      freefield4
    FROM
        [523].dbo.gbkmut
    where
        freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
      Division,
      freefield5,
      aantal,
      project,
      reknr,
      dagbknr,
      oms25,
      bdr_hfl,
      debnr,
      crdnr,
      kstplcode,
      kstdrcode,
      freefield1,
      freefield2,
      freefield3,
      freefield4
    FROM
        [524].dbo.gbkmut
    where
        freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
      Division,
      freefield5,
      aantal,
      project,
      reknr,
      dagbknr,
      oms25,
      bdr_hfl,
      debnr,
      crdnr,
      kstplcode,
      kstdrcode,
      freefield1,
      freefield2,
      freefield3,
      freefield4
    FROM
        [525].dbo.gbkmut
    where
        freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
      Division,
      freefield5,
      aantal,
      project,
      reknr,
      dagbknr,
      oms25,
      bdr_hfl,
      debnr,
      crdnr,
      kstplcode,
      kstdrcode,
      freefield1,
      freefield2,
      freefield3,
      freefield4
        freefield5
    FROM
        [527].dbo.gbkmut
    where
        freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
      Division,
      freefield5,
      aantal,
      project,
      reknr,
      dagbknr,
      oms25,
      bdr_hfl,
      debnr,
      crdnr,
      kstplcode,
      kstdrcode,
      freefield1,
      freefield2,
      freefield3,
      freefield4
    FROM
        [528].dbo.gbkmut
    where
        freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
      Division,
      freefield5,
      aantal,
      project,
      reknr,
      dagbknr,
      oms25,
      bdr_hfl,
      debnr,
      crdnr,
      kstplcode,
      kstdrcode,
      freefield1,
      freefield2,
      freefield3,
      freefield4
    FROM
        [541].dbo.gbkmut
    where
        freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
      Division,
      freefield5,
      aantal,
      project,
      reknr,
      dagbknr,
      oms25,
      bdr_hfl,
      debnr,
      crdnr,
      kstplcode,
      kstdrcode,
      freefield1,
      freefield2,
      freefield3,
      freefield4
    FROM
        [561].dbo.gbkmut
    where
        freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
      Division,
      freefield5,
      aantal,
      project,
      reknr,
      dagbknr,
      oms25,
      bdr_hfl,
      debnr,
      crdnr,
      kstplcode,
      kstdrcode,
      freefield1,
      freefield2,
      freefield3,
      freefield4
    FROM
        [547].dbo.gbkmut
    where
        freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
      Division,
      freefield5,
      aantal,
      project,
      reknr,
      dagbknr,
      oms25,
      bdr_hfl,
      debnr,
      crdnr,
      kstplcode,
      kstdrcode,
      freefield1,
      freefield2,
      freefield3,
      freefield4
    FROM
        [512].dbo.gbkmut
    where
        freefield5 is not null
      and dagbknr in (' 98' , ' 99')

  ) AS alleurenids ON SUR.UrenregistratieRegelID = alleurenids.freefield5

WHERE
    (SUR.Uren <> 0 or SUR.Uren is not null)
    AND SzD.YeardateYear >= 2017
    AND alleurenids.freefield5 is null
    AND LEN(SO.Werknummer) >= 8
    AND SUR.Uren <> 0
--    AND SUR.UrenregistratieRegelID IS NULL
--    AND datepart(yyyy, SUR.DatumUrenReg) >= 2017

/* =============== Controle tabel Sagrosoft - Exact Globe ====================== */
) AS ControleTabel ON SUR.UrenregistratieRegelID = ControleTabel.UrenregistratieRegelID


WHERE
	SUR.Uren is not null
	/* onderstaande regel niet meenemen, zodat alle uren worden geboekt en dus al het personeel wordt aangemaakt */
	/* and right([dbo].[tblUrenRegistratieRegel].[ProjectNr],4) NOT IN ('4400', '4450', '4813') */
	and SUR.Uren <> 0
	and datepart(yyyy, SUR.[DatumUrenReg]) >= 2017
	and SUR.[ProjectNr] not like '99%'
--    and SUR.UrenregistratieRegelID is NULL
    and ControleTabel.UrenregistratieRegelID is NULL
	and len(SP.PersoneelNo) >= 7
