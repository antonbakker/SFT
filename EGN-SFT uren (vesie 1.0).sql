




/* Selectie EGN */

DECLARE @name VARCHAR(50) -- database name 
 
DECLARE db_cursor CURSOR FOR 
SELECT name
FROM master.dbo.sysdatabases
/* WHERE name IN ('521') */  -- include these databases
WHERE name IN ('512', '513', '514', '521', '522', '523', '524', '525', '527', '528', '541', '542', '543', '544', '561', '571', '581', '582', '583', '591', '593', '594')  -- include these databases
/* WHERE name IN ('012', '013', '014', '021', '022', '023', '024', '025', '027', '028', '041', '042', '043', '044', '061', '071', '081', '082', '083', '091', '093', '094') */  -- include these databases
/* WHERE name IN ('521') */
 
 
OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @name  
 
WHILE @@FETCH_STATUS = 0  
BEGIN

DECLARE @query VARCHAR(MAX)

/* Projecten */
SET @query =
'
SELECT
    GBM.freefield5,
    DT.[YEAR],
    DT.[MONTH] AS Month,
    DT.[ISO_WEEK_NO] AS WeekNo,
    GBM.reknr,
    RKN.[oms25_0] AS RekeningOmschrijving,
    GBM.tegreknr,
    TGN.[oms25_0] AS TegenrekeningOmschrijving,
    GBM.dagbknr,
    DB.[oms25_0] AS DagboekOmschrijving,
    GBM.oms25 AS GbkmutOmschrijving,
    GBM.[bdr_hfl] AS Bedrag,
    GBM.[btw_code] AS BTWcode,
    BTR.[oms30_0] AS BTWomschrijving,
    GBM.[btw_bdr_3] AS BTW,
    CASE
        WHEN GBM.debnr is not NULL THEN DEB.[cmp_code]
        WHEN GBM.crdnr is not NULL THEN CRD.[cmp_code]
    END AS Relatiecode,
    CASE
        WHEN GBM.debnr is not NULL THEN DEB.[cmp_name]
        WHEN GBM.crdnr is not NULL THEN CRD.[cmp_name]
    END AS RelatieNaam,
    KPL.kstplcode,
    KPL.[oms25_0] AS KostenplaatsOmschrijving,
    GBM.kstdrcode,
    KDR.[oms25_0] AS KostendragerOmschrijving,
    GBM.aantal,
    BTC.betcond,
    BTC.[oms30_0] AS BetaalconditieOmdschrijving,
    GBM.btwper,
    GBM.docnumber,
    GBM.faktuurnr,
    GBM.syscreated,
    HUR.fullname,
    GBM.sysmodified,
    GBM.sysmodifier,
    GBM.crdnr,
    BDR.bedrnr,
    BDR.bedrnm,
    GBM.freefield1,
    GBM.freefield2,
    GBM.freefield3,
    GBM.freefield4,
    PRP.Description
FROM
    [' + @name + '].[dbo].gbkmut AS GBM
    LEFT JOIN [' + @name + '].[dbo].DimTime AS DT ON GBM.datum = DT.[DATE] 
    LEFT JOIN [' + @name + '].[dbo].grtbk RKN ON GBM.reknr = RKN.reknr 
    LEFT JOIN [' + @name + '].[dbo].grtbk TGN ON GBM.reknr = TGN.reknr 
    LEFT JOIN [' + @name + '].[dbo].dagbk AS DB ON GBM.dagbknr = DB.dagbknr 
    LEFT JOIN [' + @name + '].[dbo].btwtrs AS BTR ON GBM.[btw_code] = BTR.btwtrans 
    LEFT JOIN [' + @name + '].[dbo].cicmpy AS DEB ON GBM.debnr = DEB.debnr 
    LEFT JOIN [' + @name + '].[dbo].cicmpy AS CRD ON GBM.crdnr = CRD.crdnr 
    LEFT JOIN [' + @name + '].[dbo].kstpl AS KPL ON GBM.kstplcode = KPL.kstplcode 
    LEFT JOIN [' + @name + '].[dbo].kstdr AS KDR ON GBM.kstdrcode = KDR.kstdrcode 
    LEFT JOIN [' + @name + '].[dbo].betcd AS BTC ON BTC.betcond = GBM.betcond 
    LEFT JOIN [' + @name + '].[dbo].humres AS HUR ON HUR.[res_id] = GBM.syscreator 
    LEFT JOIN [' + @name + '].[dbo].bedryf AS BDR ON BDR.bedrnr = GBM.CompanyCode 
    LEFT JOIN [' + @name + '].[dbo].PRProject AS PRP ON PRP.ProjectNr = GBM.project
'

EXEC( @query)

 
  FETCH NEXT FROM db_cursor INTO @name  
END  
 
CLOSE db_cursor  
DEALLOCATE db_cursor






/* Selectie waarden Sagrosoft */

SELECT
    TUR.UrenregistratieRegelID,
    ZYD.WeekNo,
    ZYD.YeardateYear AS Year,
    TUR.DatumUrenReg AS Datum,
    TPR.PersoneelNo,
    ZBR.Bedrijfsnaam,
    TPR.Beroep,
    TPR.VolledigeNaam,
    TPR.Actief AS PersoneelActief,
    ZAG.Waarde AS Personeelstype,
    TPI.OpdrachtOmschrijving,
    TMR.Eigenaar AS MeterieelEigenaan,
    TMR.KostenPlaats,
    TMR.Omschrijving AS MaterieelOmschrijving,
    TMR.Groep AS MaterieelGroep,
    TMR.Kenteken,
    TMR.Actief AS MeterieelActief,
    TMR.TariefIntern AS TariefInternMaterieel,
    TPR.TariefIntern AS TariefInternPersoneel,
    TUR.Uren,
    TUR.Opmerking,
    TUR.HulpstukId,
    TUR.HulpstukId2
FROM
    [BB-SERVER\SQLEXPRESS].[Sagro_backend].[dbo].zLookupYearDays AS ZYD
    RIGHT JOIN [BB-SERVER\SQLEXPRESS].[Sagro_backend].[dbo].tblUrenRegistratieRegel AS TUR ON ZYD.Yeardate = TUR.DatumUrenReg 
    LEFT JOIN [BB-SERVER\SQLEXPRESS].[Sagro_backend].[dbo].tblPersoneel AS TPR ON TUR.PersoneelID = TPR.PersoneelID 
    LEFT JOIN [BB-SERVER\SQLEXPRESS].[Sagro_backend].[dbo].tblOpdracht AS TPI ON TUR.OpdrachtID = TPI.OpdrachtID 
    LEFT JOIN [BB-SERVER\SQLEXPRESS].[Sagro_backend].[dbo].zLookupBedrijven AS ZBR ON TPR.WerkgeverBV = ZBR.BedrijfsID 
    LEFT JOIN [BB-SERVER\SQLEXPRESS].[Sagro_backend].[dbo].tblMaterieel AS TMR ON TUR.MaterieelID = TMR.MaterieelID 
    LEFT JOIN [BB-SERVER\SQLEXPRESS].[Sagro_backend].[dbo].zLookupAlgemeen AS ZAG ON TPR.PersoneelType = ZAG.ID