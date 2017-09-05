CREATE VIEW QTEMP.LMCALDV
AS
Select
	MONTH(ISODAT - (DAYOFWEEK(ISODAT)-1) DAYS) aomonth,
	YEAR(ISODAT - (DAYOFWEEK(ISODAT)-1) DAYS) aoyear,
	CAL.*
From 
	(
		select
		 Case
			When aoaddt/1000000 >=1 then
			   DATE('20'||substr(aoaddt,2,2)||'-'||substr(aoaddt,4,2)||'-'||substr(aoaddt,6,2))
			When aoaddt/1000000 <1 then
			   DATE('19'||substr(aoaddt,1,2)||'-'||substr(aoaddt,3,2)||'-'||substr(aoaddt,5,2))
		 end ISODAT,
		 sgcaldp.*
		From sgcaldp
	) CAL
	
	
