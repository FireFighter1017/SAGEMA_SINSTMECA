SELECT 
   BOKEYX BT,
   BNKEY1 DIV, 
   BNJ7CD UL, 
   CZF3NA DESC_UL, 
   BNJ4CD FNCT, 
   CWF2NA DESC_FNCT, 
   BNACCD EQ, 
   BNDATX DESC_EQ,
   BOKACD TYPE_BT,
   BNJ2CD CRIT, 
   BNCOND COND, 
   DFJ1CD TACHE, 
   DFAPNA DESC_TACHE, 
   DFA7NA FREQ,
   DJBSCD ATE,
   DJBUCD MET,
	DTEN.ISODAT CRTDAT,
	DTEN.aoYEAR CRTYR,
	DTEN.AOMONTH CRTMTH,
	DTEN.AOAQNB CRTWK,
	DTAC.ISODAT CLSDAT,
	DTAC.AOYEAR CLSYR,
	DTAC.AOMONTH CLSMTH,
	DTAC.AOAQNB CLSWK,
	DTAD.ISODAT SCDDAT,
	DTAD.AOYEAR SCDYR,
	DTAD.AOMONTH SCDMTH,
	DTAD.AOAQNB SCDWK,	
	DTRE.ISODAT DUEDAT,
	DTRE.AOYEAR DUEYR,
	DTRE.AOMONTH DUEMTH,
	DTRE.AOAQNB DUEWK,
	CASE
      WHEN (DJEWNB+djovnb)- (DJNBHR+DJNBHS) < 0 THEN 0
      ELSE (DJEWNB+djovnb)- (DJNBHR+DJNBHS)
   END REM_TIME,
   1 CNT,
	boa7na REMARK,
	-- Compliance Determination
	--   In order to be compliant, a Work Order need to be closed
	--   in the same week they were scheduled in 451, 
	--   and it has a "closed" state. 
	CASE
		WHEN DTAC.AOYEAR = DTRE.AOYEAR AND DTAC.AOAQNB = DTRE.AOAQNB AND BOETAT IN ('7','4') THEN 1
		ELSE 0
	END COMPLIANCE,
	days(dtac.isodat) days_closed,
	days(dtre.isodat) days_due,
	DAYS(DTAC.ISODAT)-DAYS(DTRE.ISODAT) DIFF,
	ABS(DAYS(DTAC.ISODAT)-DAYS(DTRE.ISODAT)) ABS_DIFF	
	
FROM SGBOAML9 
JOIN SGBONTlk on bokeyx=djkeyx 
LEFT JOIN SGEQUIP ON BNACCD = BOACCD
LEFT JOIN SGLOCAP ON CWJ4CD = BNJ4CD
LEFT JOIN SGBATIP ON CZJ7CD = BNJ7CD
LEFT JOIN SGTRAVP ON DFACCD = BNACCD AND DFJ1CD = BOJ1CD
LEFT JOIN SGTRAMP ON DGACCD = DFACCD AND DGJ1CD = DFJ1CD
-- Get Issue date periods
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
-- Get Scheduled Start Date periods
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
-- Get Completed Date Periods
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
-- Get Requested Date Periods
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
					) CAL) DTRE on DTRE.aoaddt=bodtre
					
WHERE 
  TRIM(BOACCD)||TRIM(BOJ1CD) IN (SELECT TRIM(DLACCD)||TRIM(DLJ1CD) FROM SGTRCDP) 
  AND BOKACD IN ('P','PA','PM','PS') 
  and DTRE.aoyear=YEAR(CURRENT_DATE)
  AND DTRE.ISODAT < CURRENT_DATE
  