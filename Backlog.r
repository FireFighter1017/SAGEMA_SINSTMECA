# ---- backlogLoadFromFile ----
backlog = read_xlsx('Backlog.xlsx', col_names = TRUE, range='A2:F182')

# ---- backlogLoadFromKPI ----
  
  start_year = year(Sys.Date())-4
  end_year = year(Sys.Date())
  years = start_year:end_year
  path = 'P:/038/Groupes/Fiabilité_Maintenance/GMAO/KPI/Indicateurs Hebdo KF/Backlog'
  backlog = data.frame()
  xl = data.frame()
  ## Read current year's
  
  for(i in years){
    p = paste(path,i,sep='/')
    exist = list.files(p, '^backlog ELEC Total', recursive=TRUE, full.names = TRUE, ignore.case = TRUE)
    if(length(exist)>0){
      xl = read_xlsx(exist, range='A1:BA23', col_names = FALSE)
      temp = as.data.frame(t(xl))
      colnames(temp) = c(xl$X__1)
      xl = temp
      xl$src=address(i)
    }
    exist = list.files(p, '^KPI_10024_038E', recursive=TRUE, full.names = TRUE, ignore.case = TRUE)
    if(length(exist)>0){
      xl = read_xlsx(exist, range='A1:BA23', col_names = FALSE)
      temp = as.data.frame(t(xl))
      colnames(temp) = c(xl$X__1)
      xl = temp
      xl$src=address(i)
    }
    backlog = rbind(backlog,xl)
    
  }

# ---- backlogTidy ----
  
  backlog$period = factor(paste(backlog$ANNEE, str_pad(backlog$SEM, 2, 'left', '0'), sep=''))
  periods = unique(backlog$period)
  backlog = arrange(backlog, period)
  
  
# ---- backlogPlotByWeek ----
  
  gdf = backlog[!is.na(backlog$H_SIM),]
  g1 = ggplot(data=gdf, aes(as.numeric(period), H_SIM))
  g1 = g1 + geom_point()
  g1 = g1 + stat_smooth(method=lm)
  g1 = g1 + scale_x_continuous(name="Semaine", 
                               breaks=grep('01',substr(gdf$period,5,6)), 
                               labels=unique(gdf$ANNEE))
  g1 = g1 + labs(title='Backlog en heures par semaine.',
                 subtitle='SINST-MECA',
                 y='Heures estimées')
  g1 = g1 + geom_vline(xintercept = grep('201501',gdf$period)-0.5, linetype=2)
  g1 = g1 + geom_vline(xintercept = grep('201601',gdf$period)-0.5, linetype=2)
  g1 = g1 + geom_vline(xintercept = grep('201701',gdf$period)-0.5, linetype=2)
  g1
