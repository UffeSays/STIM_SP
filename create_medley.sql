USE [datalake]
GO
/****** Object:  StoredProcedure [dbo].[create_medley_rightsholders]    Script Date: 2018-01-25 12:57:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[create_medley_rightsholders]
AS

-- Skapar dimensiontabell för medlemsdata (upphovspersoner och förlag) 
-- Hämtas från temp-tabellen for_dm_medley_for_dIpBase som skapas för att ladda Troy-avräkning
--
-- Typiskt för att ladda ett år körs:
-- * create_troy_tmptables
-- * create_troy_dimtables
-- * create_troy_fAPS
-- * create_troy_fRES
-- * create_tory_fNCB
-- * create_medley_rightsholders

IF OBJECT_ID('datamarts.dMedleyRightsholders', 'U') IS NOT NULL DROP TABLE datamarts.dMedleyRightsholders

-- Hantera att det kan finnas flera IPBaseKey som har samma Medlemsnummer (ca. 20-tal) genom att ta den lägsta i IPBaseKey-kolumnen och lägga upp ev. extra BaseKeys i Extra-kolumnen. 
-- Namnen hanteras genom att alltid ha dem i en ;-separerad lista om det är flera
-- Om inte hanterades så skulle vi ha fått multipla rader med samma medlemmsnummer
SELECT md.*, 
(SELECT MIN(ib.IPBaseKey) AS ipbk FROM datamarts.dIPBaseName ib WHERE md.MdlMedlemsnr = ib.MdlMedlemsnr) AS TroyIceIPBaseKeyFirst,
	SUBSTRING(
		(SELECT DISTINCT ', ' + CONVERT(varchar, ib.IPBaseKey) FROM datamarts.dIPBaseName ib 
		WHERE md.MdlMedlemsnr = ib.MdlMedlemsnr AND ib.IPBaseKey not in (SELECT MIN(ib.IPBaseKey) AS ipbk FROM datamarts.dIPBaseName ib WHERE md.MdlMedlemsnr = ib.MdlMedlemsnr)
		ORDER BY ', ' + CONVERT(varchar, ib.IPBaseKey) FOR XML PATH('')),
		3, 99999
) AS TroyIceIPBaseKeyExtra,
SUBSTRING(
	(SELECT DISTINCT ';' + ib.IPBaseName FROM datamarts.dIPBaseName ib WHERE md.MdlMedlemsnr = ib.MdlMedlemsnr FOR XML PATH('')),
	2, 99999
) AS TroyIceIPBaseName
--ib.IPBaseKey AS TroyIceIPBaseKey, ib.IPBaseName AS TroyIceIPBaseName
INTO datamarts.dMedleyRightsholders
FROM tmp.for_dm_medley_for_dIpBase md
