set transaction isolation level read uncommitted

SELECT
    SzB.Bedrijfsnaam,
    SP.VolledigeNaam,
    SzD.YeardateYear,
    SzD.WeekNo,
    SUR.DatumUrenReg,
    SUR.Uren,
    SO.Werknummer,
    SO.OpdrachtOmschrijving
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
WHERE
    (SUR.Uren <> 0 or SUR.Uren is not null)
    AND SzD.YeardateYear >= 2017
--    AND datepart(yyyy, SUR.DatumUrenReg) >= 2017
    and SUR.UrenregistratieRegelID in (
    Select Urenid FROM
(
SELECT DISTINCT  QU.Urenid,Referentie, Aanmaakdatum, ProjectNr
FROM
  (
    SELECT
      freefield5
    FROM
      [521].dbo.gbkmut
    where
      freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
      freefield5
    FROM
      [522].dbo.gbkmut
    where
      freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
        freefield5
    FROM
        [523].dbo.gbkmut
    where
        freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
        freefield5
    FROM
        [524].dbo.gbkmut
    where
        freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
        freefield5
    FROM
        [525].dbo.gbkmut
    where
        freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
        freefield5
    FROM
        [527].dbo.gbkmut
    where
        freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
        freefield5
    FROM
        [528].dbo.gbkmut
    where
        freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
        freefield5
    FROM
        [541].dbo.gbkmut
    where
        freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
        freefield5
    FROM
        [561].dbo.gbkmut
    where
        freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
        freefield5
    FROM
        [547].dbo.gbkmut
    where
        freefield5 is not null
      and dagbknr in (' 98' , ' 99')

    UNION ALL

    SELECT
        freefield5
    FROM
        [512].dbo.gbkmut
    where
        freefield5 is not null
      and dagbknr in (' 98' , ' 99')

  ) AS alleurenids

  RIGHT OUTER JOIN [DB3].[QDWH].[dbo].Qurencontrole AS QU ON alleurenids.freefield5 = QU.Urenid
  
  WHERE
    (alleurenids.freefield5 IS NULL)
    and Referentie is not null
    and  left (Projectnr,2) <> '43'
    -- and datepart(yyyy,Aanmaakdatum) >= 2017

  -- order by 4
) AS QR1
)
GROUP BY 
    SzB.Bedrijfsnaam,
    SP.VolledigeNaam,
    SzD.YeardateYear,
    SzD.WeekNo,
    SUR.DatumUrenReg,
    SUR.Uren,
    SO.Werknummer,
    SO.OpdrachtOmschrijving
ORDER By SUR.DatumUrenReg