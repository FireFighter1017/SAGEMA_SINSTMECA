
SELECT
	sgboaml9.*,
	sgbontlk.*,
	DTEN.ISODAT CRTDAT,
	DTEN.aoYEAR CRTYR,
	DTEN.AOMONTH CRTMTH,
	DTEN.AOAQNB CRTWK,
	DTAC.ISODAT CLSDAT,
	DTAC.AOMONTH CLSMTH,
	DTAC.AOAQNB CLSWK,
	DTAD.ISODAT DUEDAT,
	DTAD.AOYEAR DUEYR,
	DTAD.AOMONTH DUEMTH,
	DTAD.AOAQNB DUEWK,	
   CASE
      WHEN (DJEWNB+djovnb)- (DJNBHR+DJNBHS) < 0 THEN 0
      ELSE (DJEWNB+djovnb)- (DJNBHR+DJNBHS)
   END REM_TIME,
   1 CNT,
	boa7na REMARK
	
FROM SGBOAML9 
JOIN SGBONTlk on bokeyx=djkeyx 
join (Select
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
			) CAL) DTEN on DTEN.aoaddt=bodten
left JOIN ( Select
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
					) CAL) DTAD ON DTAD.aoaddt=bodtad
left join ( Select
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
					) CAL) DTAC on DTAC.aoaddt=bodtac

WHERE TRIM(BOACCD)||TRIM(BOJ1CD) IN (SELECT TRIM(DLACCD)||TRIM(DLJ1CD) FROM SGTRCDP) AND BOKACD IN ('P','PA','PM','PS')