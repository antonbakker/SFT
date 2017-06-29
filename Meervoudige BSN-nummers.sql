
SELECT
*
FROM
dbo.tblPersoneel
WHERE BSN IN (

SELECT BSN FROM
(
SELECT
dbo.tblPersoneel.BSN,
COUNT(dbo.tblPersoneel.PersoneelID) AS Aantal
FROM
dbo.tblPersoneel
JOIN dbo.zLookupBedrijven
ON dbo.tblPersoneel.WerkgeverBV = dbo.zLookupBedrijven.BedrijfsID
WHERE dbo.tblPersoneel.Actief = 1
GROUP BY
dbo.tblPersoneel.BSN

) AS QRYT
WHERE Aantal > 1


)