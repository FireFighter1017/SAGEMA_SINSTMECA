##==============================
## Work Order HISTORY (WOD)
##==============================

# ---- WODLoadFromDB -----

cx = dbConnect(drv, connURL, usr, pwd)

## Read table
sqlcmd = read_file('./SQL/WorkOrderHistory.sql')
WOD = dbGetQuery(cx, sqlcmd)
fwrite(WOD, "PPMHistory.csv")

dbDisconnect(cx)
colcls = sapply(WOD, class)
save(list=colcls, file='PPMHistory_colcls.RData')

# ---- WODLoadFromFile ----
# colcls = load('PPMHistory_colcls.RData')
# WOD = fread("PPMHistory.csv", 
#             stringsAsFactors=TRUE, 
#             header=TRUE, 
#             colClasses = list(factor=grep('factor', colcls)),
#             encoding='UTF-8')

# ---- WODTidy ----
WOD$TYPE_BT = factor(trimws(WOD$TYPE_BT))
WOD$EQ = factor(WOD$EQ)
WOD$CRTYR = factor(WOD$CRTYR)
WOD$CRTMTH = factor(WOD$CRTMTH)
WOD$CRTWK = factor(WOD$CRTWK)
WOD$CRTPER = paste(WOD$CRTYR, str_pad(WOD$CRTMTH, 2, side=c("left"), pad="0"), sep="-")
WOD$CLSYR = factor(substr(WOD$CLSDAT,1,4))
WOD$CLSMTH = factor(WOD$CLSMTH)
WOD$CLSWK = factor(WOD$CLSWK)
WOD$CLSPER = paste(WOD$CLSYR, str_pad(WOD$CLSMTH, 2, side=c("left"), pad="0"), sep="-")
WOD$DUEYR = factor(year(WOD$DUEDAT))
WOD$DUEMTH = factor(WOD$DUEMTH)
WOD$DUEWK = factor(WOD$DUEWK)
WOD$DUEPER = paste(WOD$CRTYR, str_pad(WOD$CRTMTH, 2, side=c("left"), pad="0"), sep="-")
WOD$TYPECAT[substr(WOD$TYPE_BT,2,2) %in% c('1','2','D',' ')] = 'Non-planifié'
WOD$TYPECAT[substr(WOD$TYPE_BT,2,2) %in% c('3','A')] = 'Planifié'
WOD$TYPECAT = factor(WOD$TYPECAT)
WOD$TYPECAT2[substr(WOD$TYPE_BT,1,1) %in% c('C')] = 'Correctif'
WOD$TYPECAT2[substr(WOD$TYPE_BT,1,1) %in% c('M')] = 'Modification'
WOD$TYPECAT2[substr(WOD$TYPE_BT,1,1) %in% c('P')] = 'Préventif'
WOD$TYPECAT2[substr(WOD$TYPE_BT,1,1) %in% c('D')] = 'Gestion'
WOD$TYPECAT2 = factor(WOD$TYPECAT2)
WOD$planYN = substr(WOD$TYPE_BT,2,2) %in% c('3','A')
WOD$prevYN = WOD$TYPE_BT %in% c('P','PM','PA','PS')
WOD$shutYN = WOD$TYPE_BT %in% c('CA','MA','PA','PS')
WOD$corrYN = WOD$TYPE_BT %in% c('C3','CA','C1','C2')
WOD$modYN = WOD$TYPE_BT %in% c('M3','MA')
WOD$urgYN = WOD$TYPE_BT %in% c('C1')

fwrite(WOD, 'PPMHistoryTidy.csv')
colcls = sapply(WOD, class)
save(list=colcls, file='PPMHistoryTidy_colcls.RData')


# ---- PGMLoadFromDB -----
cx = dbConnect(drv, connURL, usr, pwd)

## Read table
sqlcmd = read_file('./SQL/PPMProgram.sql')
dta = dbGetQuery(cx, sqlcmd)
write_csv(dta, "PPMProgram.csv")
colcls = sapply(dta, class)
save(list=colcls, file='PPMProgram_colcls.RData')
pmp = dta
remove(dta)
dbDisconnect(cx)

## ---- Tidy up pmp
pmp$YEAR = factor(pmp$YEAR)
pmp$WEEKNO = factor(pmp$WEEKNO)
pmp$EQ = factor(pmp$EQ)
pmp$TACHE = factor(pmp$TACHE)

## ---- Prepare tables for joining
pmp1 = unique(pmp[pmp$YEAR==year(now()) & as.numeric(as.character(pmp$WEEKNO))<=week(now()),c('EQ','TACHE','YEAR','WEEKNO')])
WOD1 = unique(WOD[WOD$DUEYR==year(now()) & as.numeric(as.character(WOD$DUEWK))<=week(now()),c('CNT','EQ','TACHE','DUEYR','DUEWK')])
jn = left_join(pmp1, WOD1, by=c('EQ'='EQ','TACHE'='TACHE','YEAR'='DUEYR','WEEKNO'='DUEWK'))
gdf = group_by(jn, EQ, TACHE, YEAR, WEEKNO)
gdf = summarise(gdf, compliance=mean(!is.na(CNT)))
summary(gdf$compliance)
unique(gdf$compliance)
