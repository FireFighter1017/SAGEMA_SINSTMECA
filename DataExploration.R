








## Moyenne par année
mby = aggregate(HRS~YR, sum_by_MTH, mean)


freqData <- as.data.frame(table(sum_by_MTH$YR, sum_by_MTH$SUMHRS))
names(freqData) <- c("X", "Y", "freq")

freqData$Y <- as.numeric(as.character(freqData$Y))
freqData$X <- as.numeric(as.character(freqData$X))
myPlot <- function(beta){
  g <- ggplot(filter(freqData, freq > 0), aes(x = X, y = Y))
  g <- g  + scale_size(range = c(min(X), max(Y)), guide = "none" )
  g <- g + geom_point(colour="grey50", aes(size = freq+20, show_guide = FALSE))
  g <- g + geom_point(aes(colour=freq, size = freq))
  g <- g + scale_colour_gradient(low = "lightblue", high="white")                     
  g <- g + geom_abline(intercept = 0, slope = beta, size = 3)
  mse <- mean( (y - beta * x) ^2 )
  g <- g + ggtitle(paste("beta = ", beta, "mse = ", round(mse, 3)))
  g
}
manipulate(myPlot(beta), beta = slider(0.6, 1.2, step = 0.02))




## Modeling something with work order issued using cut2 and stepAIC
## Not sure if this is worth something
dsfp = WOD2[,c(85:87,98:102)]
dsfp$per = (100*as.numeric(as.character(dsfp$CRTYR))) + as.numeric(as.character(dsfp$CRTWK))
dsfp = group_by(dsfp, CRTYR, CRTMTH, CRTWK) %>% summarise(p_prev=mean(sum(prevYN)), 
                                                          p_shut=mean(sum(shutYN)), 
                                                          p_corr=mean(sum(corrYN)),
                                                          p_mod=mean(sum(modYN)),
                                                          p_run =mean(sum(runYN)),
                                                          tothrs=sum(!is.na(per)))
dsfp$tothrsCut = cut2(dsfp$tothrs, g=6)

featurePlot(x=dsfp[,c(4:8)], y=dsfp$tothrsCut, plot="pairs")
hist(log(dsfp$tothrs))
summary(dsfp$tothrsCut)
mdl = glm(tothrsCut~p_prev+p_corr+p_mod+p_run, data=dsfp)
feat = stepAIC(mdl, trace=FALSE)
summary(feat)
gdf1 = data.frame(YR=as.numeric(gdf$YR), WK=gdf$WK, tothrs=gdf$tothrs, prevYN=as.numeric(gdf$prevYN))



## Trying to find a model on WO type  
gdf = group_by(pData, CRTWK, BOKACD) 
gdf = summarise(gdf, nIssued=sum(!is.na(BOKEYX)), piPrev=count(BOKACD[BOKACD %in% c('P','PA')]))
mdl = glm(nIssued ~ BOKACD, family=poisson, data=gdf)
  
  

  bm = group_by(WOD2, factor(CRTYR), as.numeric(CRTMTH), BOKACD) %>% summarise(count=sum(!is.na(BOKEYX)))
  
  md = lm(count ~ TYPECAT2, data = bm[bm$TYPECAT2 %in% c('C3','CA','P '),])
  summary(md)

hist(bm$count[I(bm$TYPECAT2)=='Correctif'])

## === CLOSED WORK ORDERS ===
wc_by_MTH = group_by(WOD2, CLSYR, CLSMTH)
c = summarise(wc_by_MTH, count=n_distinct(BOKEYX))
qplot(c$count, c$CLSYR)

