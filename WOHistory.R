
##=======================
##    WORKED HOURS (WH)
##=======================

# ---- WHLoadFromDB ----
  cx = dbConnect(drv, connURL, 'u038pbel','SEitl038')
  # cx <- odbcDriverConnect(paste("DRIVER=iSeries Access ODBC Driver;",
  #                               "SYSTEM=", dbname, ";",
  #                               "DBQ=", libname, ";",
  #                               "uid=", usr, ";",
  #                               "Password=", pwd, ";", sep=""))
  sqlcmd = read_file("./SQL/WorkedHoursHistory.sql")
  # dta <- sqlQuery(cx, sqlcmd)
  WH = dbGetQuery(cx, sqlcmd)
  write_csv(WH, "WorkedHours_038_2010_2016.csv")
  dbDisconnect(cx)
  

# ---- WHLoadFromFile ----
  fread('WorkedHours_038_2010_2016.csv', header=TRUE)

# ---- WHTidy ----

  ## Préparation des données  
  ## Enlever les BT test ou bidon
  dta = filter(dta, !(trimws(WO)==",") & !(trimws(WO)=="<") & !(trimws(WO)=="*"))
  
  ## Créer une colonne qui contiendra une période combinée de l'année et du mois de la date de travail.  
  ## Et créer une colonne indice de période. 
  dta = mutate(dta, period=paste(dta$YR, "-", str_pad(dta$MTH, 2, pad="0"), sep=""))
  per = c(seq(1:length(unique(dta$period))), unique(dta$period))
  per = data.frame("perno" = seq(1:length(unique(dta$period))), "period" = unique(dta$period))
  per$period = as.character(per$period)
  dta = inner_join(dta,per)
  
  ## Formatter la date
  dta$isodat = paste('20',dta$WRKDATE,sep='')
  dta$week = week(POSIXct(dta$isodat))
  
  ## Filter data as per requirements
  dta = subset(dta, TYPE %in% c("C3","M3","D3","P","PA","CA","MA"))
  dta = subset(dta, SHOP %in% c("SELEC ","SINST ") & TRADE %in% c("MECA  ","MOTEUR"))
  
  ## Nettoyer les variables qui contiennent des blanc au début ou à la fin des valeurs
  dta$DIV_NAME = trimws(dta$DIV_NAME)
  dta$TYPE = trimws(dta$TYPE)
  dta$SHOP = trimws(dta$SHOP)
  dta$TRADE = trimws(dta$TRADE)
  dta$BOKACD = trimws(dta$BOKACD) 


# ---- WHStats ----
  
  ## Description des données analysées
  str(dta)
  summary(dta)
  unique(paste(trimws(dta$DIV), trimws(dta$DIV_NAME), sep="-"))
  unique(paste(trimws(dta$SHOP), trimws(dta$TRADE), sep="-"))
  
  
  ## Données Statistiques
  
  dta_by_MTH = group_by(dta, YR, MTH)
  sum_by_MTH = summarise(dta_by_MTH, sum(HRS))
  colnames(sum_by_MTH) = c("YR", "MTH", "HRS")
  
  mu = mean(sum_by_MTH$HRS)
  sigma = sd(sum_by_MTH$HRS)
  n = length(sum_by_MTH$HRS)
  ci = mu + c(-1, 1) * qnorm(0.975) * sigma/sqrt(n)
  dev = sum_by_MTH$HRS - mu
  
  hdev = ggplot(sum_by_MTH, aes(x = HRS))
  hdev = hdev + geom_histogram(fill = I("salmon"))
  hdev = hdev + geom_vline(xintercept=mu, size = 2)
  hdev = hdev + geom_vline(xintercept=ci[1], size = 2, colour=I("green"), linetype=2)
  hdev = hdev + geom_vline(xintercept=ci[2], size = 2, colour=I("green"), linetype=2)
  hdev = hdev + geom_labs(title='Heures travaillées par mois')
  hdev
  ggsave("./fig/Heures travaillées par mois.png", width = 6, height = 4)



  
##==============================
## Work Order Details (WOD)
##==============================

# ---- WODLoadFromDB -----

  cx = dbConnect(drv, connURL, usr, pwd)
  
  ## Create temp calendar view
  sqlcmd = read_file('./SQL/VEW_LMCALDV.sql')
  res = dbExecute(cx, sqlcmd)
  
  ## Read table
  sqlcmd = read_file('./SQL/WorkOrdersDetails.sql')
  WOD = dbGetQuery(cx, sqlcmd)
  fwrite(WOD, "WorkOrdersDetails.csv")
  sqlcmd = "drop view QTEMP.LMCALDV"
  res = dbExecute(cx, sqlcmd)
  
  dbDisconnect(cx)
  colcls = sapply(WOD, class)
  save(list=colcls, file='WOD_colcls.RData')

# ---- WODLoadFromFile ----
  colcls = load('WOD_colcls.RData')
  WOD = fread("WorkOrdersDetails.csv", 
              stringsAsFactors=TRUE, 
              header=TRUE, 
              colClasses = list(factor=grep('factor', colcls)),
              encoding='UTF-8')

# ---- WODTidy ----
  WOD$BOKACD = factor(trimws(WOD$BOKACD))
  WOD$BOACCD = factor(WOD$BOACCD)
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
  WOD$TYPECAT[substr(WOD$BOKACD,2,2) %in% c('1','2','D',' ')] = 'Non-planifié'
  WOD$TYPECAT[substr(WOD$BOKACD,2,2) %in% c('3','A')] = 'Planifié'
  WOD$TYPECAT = factor(WOD$TYPECAT)
  WOD$TYPECAT2[substr(WOD$BOKACD,1,1) %in% c('C')] = 'Correctif'
  WOD$TYPECAT2[substr(WOD$BOKACD,1,1) %in% c('M')] = 'Modification'
  WOD$TYPECAT2[substr(WOD$BOKACD,1,1) %in% c('P')] = 'Préventif'
  WOD$TYPECAT2[substr(WOD$BOKACD,1,1) %in% c('D')] = 'Gestion'
  WOD$TYPECAT2 = factor(WOD$TYPECAT2)
  WOD$prevYN = WOD$BOKACD %in% c('P','PM','PA','PS')
  WOD$shutYN = WOD$BOKACD %in% c('CA','MA','PA','PS')
  WOD$corrYN = WOD$BOKACD %in% c('C3','CA','C1','C2')
  WOD$modYN = WOD$BOKACD %in% c('M3','MA')
  WOD$runYN = WOD$BOKACD %in% c('C2','C3','M3','CS','P','PM','M2')
  fwrite(WOD, 'WODtidy.csv')
  colcls = sapply(WOD, class)
  save(list=colcls, file='WODTidy_colcls.RData')


# ---- WOD2LoadFromFile
  colcls = load('WODTidy_colcls.RData')
  
  WOD2 = fread("WODTidy.csv", 
               # stringsAsFactors=TRUE, 
               header=TRUE, 
               # colClasses = list(factor=c(38,70)),
               colClasses = colcls,
               encoding='UTF-8')  

