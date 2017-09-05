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
