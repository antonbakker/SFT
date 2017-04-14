SELECT
	datum,
	q.Project,
	[521].[dbo].prproject.Description AS Omschrijving,
	q.Omzet AS O,
	q.kosten AS K,
	q.ohwexak2,
	q.Aanneemsom AS ans,
	q.voorgecalkost,
	q.Meerwerk AS mw,
	q.fullname AS Projectleider,
		--,  q.Uitvoerder,  ***** manager is zolang uitvoerder later lid mederwerker die geen projectleider is
	[521].[dbo].PRProject.Memo AS Opmerkingen
FROM
	(
		SELECT
			PRES.project,
			CONVERT(decimal(10, 2),
			SUM(PRES.omzet)) * - 1 AS omzet,
			CONVERT(decimal(10, 2), SUM(PRES.kosten)) AS kosten,
      CONVERT(decimal(10, 2), SUM(isnull(PRES.omzet,0))) * + 1 + CONVERT(decimal(10, 2), SUM(Isnull(PRES.kosten,0))) AS ohwexak2,
      [521].[dbo].PRProject.NumberField1 AS aanneemsom,
			[521].[dbo].PRProject.NumberField2 AS voorgecalkost,
			[521].[dbo].PRProject.NumberField3 AS meerwerk,
      [521].[dbo].PRProject.Responsible,
			[521].[dbo].humres.fullname,
			[521].[dbo].PRMember.res_id,
			[521].[dbo].PRMember.IsProjectManager,
      --, PRMember_1.res_id AS Expr1,            humres_1.fullname AS Uitvoerder
      PRES.datum
    FROM
			(
			SELECT
				gm.project,
				gm.datum,
				CASE
					WHEN omzrek = 'j' THEN (gm.bdr_hfl)
				END AS omzet,
				CASE
					WHEN omzrek <> 'j' THEN (gm.bdr_hfl)
				END AS kosten
			FROM
				[521].[dbo].gbkmut AS gm
				INNER JOIN  [521].[dbo].grtbk AS gb
					ON gm.reknr = gb.reknr
			WHERE
				(gm.transtype NOT IN ('V', 'B'))
				AND (gm.transsubtype <> 'X')
				AND (gb.bal_vw = 'W')
				AND (gm.project IS NOT NULL)
				) AS PRES
				INNER JOIN [521].[dbo].PRProject
					ON PRES.project = [521].[dbo].PRProject.ProjectNr
					INNER JOIN  [521].[dbo].PRMember
						ON [521].[dbo].PRProject.ProjectNr = [521].[dbo].PRMember.ProjectNr
					INNER JOIN  [521].[dbo].humres
						ON [521].[dbo].PRMember.res_id = [521].[dbo].humres.res_id

								--INNER JOIN [521].[dbo].PRMember AS PRMember_1
								--ON [521].[dbo].PRProject.ProjectNr = PRMember_1.ProjectNr
								--			INNER JOIN  [521].[dbo].humres AS humres_1
								--			ON PRMember_1.res_id =humres_1.res_id
			--WHERE
   --                   (YEAR(PRMember_1.UntilDate) <> '2009') AND (YEAR([521].[dbo].PRMember.UntilDate) <> '2009')-- alleen leden met datum anders dan 2009 zijn uitvoerder

      GROUP BY
				PRES.project,
				[521].[dbo].PRProject.NumberField1,
				[521].[dbo].PRProject.NumberField2,
				[521].[dbo].PRProject.NumberField3,
				[521].[dbo].PRProject.Responsible,
				[521].[dbo].humres.fullname,
        [521].[dbo].PRMember.res_id,
				[521].[dbo].PRMember.IsProjectManager,
				PRES.datum
                    --,PRMember_1.res_id,PRMember_1.IsProjectManager, humres_1.fullname, PRES.datum

      HAVING
				([521].[dbo].PRMember.IsProjectManager = 1)
						--AND (PRMember_1.IsProjectManager = 0)
	) AS q
  INNER JOIN [521].[dbo].PRProject
		ON [521].[dbo].PRProject.ProjectNr = q.project
	where
		datum >= ?
		and datum <=?
		and [521].[dbo].PRProject.Status='A'
