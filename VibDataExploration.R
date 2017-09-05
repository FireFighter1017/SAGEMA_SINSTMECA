library(RODBC)
library(dplyr)
library(readr)
library(stringr)
library(manipulate)
library(ggplot2)

dbname = 'CAS036.cascades.com'
libname = 'EPIXPROD'

## Connect data base and download work order types
cx <- odbcDriverConnect(paste("dsn=EPIXSAGE;",
                              "server=", dbname, ";",
                              "libraries=", libname, ";",
                              "uid=u038pbel;",
                              "Password=SEitl038", sep=""))
sqlcmd = read_file("U:/pbellerose/~PBELLEROSE/pbellerose/2009-02-25/Mes documents/~WinSQL/SAGE/WorkedHoursHistory.sql")
dta <- sqlQuery(cx, sqlcmd)
tidy = mutate(dta, periode=paste(dta$ANNEE, "-", str_pad(dta$MOIS, 2, pad="0"), sep=""))
h = hist(tidy$TOTAL_UNITE, breaks=30)
xbar = mean(tidy$TOTAL_UNITE)
sbar = sd(tidy$TOTAL_UNITE)
n = length(tidy$TOTAL_UNITE)
ci = xbar + c(-1, 1) * qt(0.975, df=n-1) * sbar/sqrt(n)
dev = tidy$TOTAL_UNITE-xbar
hdev = hist(dev, breaks=30)

## Analyzing data for Norampac KF

d101 = filter(tidy, substr(DIV,1,3)=='101' & ANNEE > 2012 & TYPE=='P ')
myHist <- function(mu){
  mse <- mean((d101$TOTAL_UNITE - mu)^2)
  g <- ggplot(d101, aes(x = TOTAL_UNITE))
  g <- g + geom_histogram(fill = "salmon", colour = "black", binwidth=1)
  g <- g + geom_vline(xintercept = mu, size=3)
  g <- g + ggtitle(paste("mu = ", mu , ", MSE = ", round(mse,2), sep=""))
  g
}
manipulate (myHist(mu), mu = slider(min(d101$TOTAL_UNITE),max(d101$TOTAL_UNITE), step =0.5))
boxplot(d101$TOTAL_UNITE ~ d101$MOIS)
summary(d101$TOTAL_UNITE)
sd(d101$TOTAL_UNITE)
g = ggplot(filter(d101, TYPE=='P '), aes(periode, TOTAL_UNITE))
g = g + geom_point()
g
summary(d101)
mean(d101$TOTAL_UNITE)
sd(d101$TOTAL_UNITE)
xbar101 = mean(d101$TOTAL_UNITE)
sbar101 = sd(d101$TOTAL_UNITE)
n101 = length(d101$TOTAL_UNITE)
ci = xbar101 + c(-1, 1) * qt(0.975, df=n101-1) * sbar101/sqrt(n101)
z101 = (xbar101-ci[1])/(sbar101/sqrt(n101))
