
# ---- init ----
options(java.parameters = "-Xmx8G")
library(RODBC)
library(RJDBC)
library(dplyr)
library(data.table)
library(readr)
library(stringr)
library(manipulate)
library(ggplot2)
library(lubridate)
library(GGally)
library(MASS)
library(tidyverse)
library(readxl)
library(caret)
library(Hmisc)



# ---- dbConnect ----
## Connect to Database and load data
dbname = 'CAS036.cascades.com;'
libname = 'EPIXPROD CDTA038;'
drvclass = "com.ibm.as400.access.AS400JDBCDriver"
classloc = "C:/Program Files (x86)/IBM/Client Access/jt400/lib/jt400.jar"
drv = JDBC(drvclass, classloc)
usr = 'U038PBEL'
pwd = 'MasYii99'
connURL = paste('jdbc:as400://',
                dbname, 
                'libraries=', libname, 
                'translate binary=true;',
                'date format=iso;',
                sep='')

# ocx <- odbcDriverConnect(paste("DRIVER=iSeries Access ODBC Driver;",
#                               "SYSTEM=", dbname, ";",
#                               "DBQ=", libname, ";",
#                               "uid=", usr, ";",
#                               "Password=", pwd, ";", sep=""))
# dta <- sqlQuery(cx, sqlcmd)