SELECT
   MONTH(DATE('20'||D_TRANSAC)) MTH,
   D_TRANSAC WRKDATE,
   YEAR(DATE('20'||D_TRANSAC)) YR,
   trim(qry.bokey1) DIV,
   trim(d.ctdsc)||trim(d.cdes2) DIV_NAME,
   sg.bokacd TYPE,
   sg.boJ1Cd TASK,
   sg.bokeyx WO,
   sg.bodten CRTDAT,
   sg.boaccd EQ,
   sg.BOLCH1 FCT,
   sg.BOJ7CD LINE,
   ATELIER SHOP,
   METIER TRADE,
   NB_ITEM HRS

FROM QRY_TRANSA qry
JOIN sgbontlk sg ON sg.bokeyx=qry.bokeyx
JOIN cdta038.tfcosp s on s.cnose=sg.bokey2 
join cdta038.tfcodp d on d.cnodi=sg.bokey1

WHERE 
	t_transac='M'
   and D_TRANSAC between '10-01-01' and '16-12-31'
