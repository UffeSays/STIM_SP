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

SELECT md.*, ib.IPBaseKey AS TroyIceIPBaseKey, ib.IPBaseName AS TroyIceIPBaseName
INTO datamarts.dMedleyRightsholders
FROM tmp.for_dm_medley_for_dIpBase md
LEFT OUTER JOIN datamarts.dIPBaseName ib ON md.MdlMedlemsnr = ib.MdlMedlemsnr

