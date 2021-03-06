SELECT 
 PGM.*,
 TRIM(PGM.ATE)||TRIM(PGM.MET) "ATE-MET",
 DATES.aoyear "YEAR",
 DATES.WEEKNO, DATES.aomonth "MONTH",
 CASE WHEN (substr(PGM.CLND,CAST(DATES.WEEKNO AS INTEGER),1) = 'X') THEN T_EST END EST_TIME

FROM
 (
  SELECT 
   SGEQUIP.BNKEY1 DIV, 
   SGEQUIP.BNJ7CD UL, 
   SGBATIP. CZF3NA DESC_UL, 
   SGEQUIP.BNJ4CD FNCT, 
   SGLOCAP. CWF2NA DESC_FNCT, 
   SGEQUIP.BNACCD EQ, 
   SGEQUIP.BNDATX DESC_EQ, 
   SGEQUIP.BNJ2CD CRIT, 
   SGEQUIP.BNCOND COND, 
   SGTRAVP.DFJ1CD TACHE, 
   SGTRAVP.DFAPNA DESC_TACHE, 
   SGTRAVP.DFA7NA FREQ, 
   SGTRAMP.DGEWNB T_EST, 
   sgtramp.DGBSCD ATE, 
   sgtramp.DGBUCD MET, 
   SGTRAMP.DGEXNB EQUIPE, 
   SGTRAVP.DFJ2CD PRIO_BT,
   CASE  --  Matrice 3 niveaux
       WHEN BNJ2CD='B' and DFJ2CD='1' or DFJ2CD='B1' THEN 2
       WHEN BNJ2CD='A' and DFJ2CD='1' or DFJ2CD='A1' THEN 1
       WHEN BNJ2CD='C' and DFJ2CD='1' or DFJ2CD='C1' THEN 5
       WHEN BNJ2CD='A' and DFJ2CD='2' or DFJ2CD='A2' THEN 3
       WHEN BNJ2CD='B' and DFJ2CD='2' or DFJ2CD='B2' THEN 4
       WHEN BNJ2CD='C' and DFJ2CD='2' or DFJ2CD='C2' THEN 6
       WHEN BNJ2CD='A' and DFJ2CD='3' or DFJ2CD='A3' THEN 7
       WHEN BNJ2CD='B' and DFJ2CD='3' or DFJ2CD='B3' THEN 8
       WHEN BNJ2CD='C' and DFJ2CD='3' or DFJ2CD='C3' THEN 9
       ELSE 99
   END "Ordre",
   SGTRCDP.DLIMST ETAT_TRV,
   SGEQUIP.BNJ5CD GRP,
   SGEQUIP.BNJ6CD S_GRP, 
   SGTRAVP.DFJ3TX DUREE, 
   SGTRAMP.DGGINA MESURE, 
   SGTRAVP.DFJPST CLD, 
   SGTRCDP.DLKACD "TYPE BT CLD", 
   SGTRCDP.DLK5CD "IND.TRV", 
   SUBSTR(SGTRCDP.DLL1TX,1,4) "ANNEE.DEBUT", 
   SUBSTR(SGTRCDP.DLL1TX,5,4) "ANNEE.FIN", 
   SUBSTR(SGTRCDP.DLL1TX,9,3) "FREQ.CLD", 
   SUBSTR(SGTRCDP.DLL1TX,12,2) "SEM.DEBUT", 
   SGTRCDP. DLFJNB "DERN.ENTR.CLD", 
   SGTRAVP.DFJQST CMPT, 
   SGTRCPP.EFKACD "TYPE BT CMPT", 
   SGTRCPP.EFM9CD "TYPE CMPT", 
   SGTRCPP.EFNKNB "LAST CMPT", 
   SGTRCPP.EFNLNB "FRQ CMPT", 
   SGTRCPP.EFNMNB "ANTICIP CMPT", 
   (CAST('20' CONCAT SUBSTR(SGTRCPP.EFD6DT,2,2) CONCAT '-' CONCAT SUBSTR(SGTRCPP.EFD6DT,4,2) CONCAT '-' CONCAT SUBSTR(SGTRCPP.EFD6DT,6,2) AS DATE)) "DATE LAST BT", 
   SGTRCDP.DLL0TX CLND
  
  FROM 
   SGEQUIP SGEQUIP
   JOIN SGLOCAP SGLOCAP ON SGLOCAP. CWJ4CD = SGEQUIP.BNJ4CD
   JOIN SGBATIP SGBATIP ON SGBATIP. CZJ7CD = SGEQUIP.BNJ7CD
   LEFT JOIN SGTRAVP SGTRAVP ON SGTRAVP.DFACCD = SGEQUIP.BNACCD
   LEFT JOIN SGTRAMP SGTRAMP ON SGTRAmP.DgACCD = SGTRAVP.DFACCD AND SGTRAmP.DgJ1CD = SGTRAVP.DFJ1CD
   LEFT JOIN SGTRCDP SGTRCDP ON SGTRCDP.DLACCD  = SGTRAVP.DFACCD AND SGTRCDP.DLJ1CD  = SGTRAVP.DFJ1CD
   LEFT JOIN SGTRCPP SGTRCPP ON SGTRCPP.EFACCD = SGTRAVP.DFACCD AND SGTRCPP.EFJ1CD = SGTRAVP.DFJ1CD
  WHERE DLIMST<>'H'
 ) PGM,
 
 (
  SELECT DISTINCT
     MONTH(ISODAT - (DAYOFWEEK(ISODAT) - 1) DAYS) aomonth,
     YEAR(ISODAT - (DAYOFWEEK(ISODAT) - 1) DAYS) aoyear,
     AOAQNB WEEKNO
  FROM
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

  WHERE YEAR(ISODAT) >= YEAR(CURRENT_TIMESTAMP) AND YEAR(ISODAT) <= (YEAR(CURRENT_TIMESTAMP) + 1)
  ) DATES
  
 WHERE NOT(CASE WHEN (substr(PGM.CLND,CAST(DATES.WEEKNO AS INTEGER),1) = 'X') THEN T_EST END IS NULL)