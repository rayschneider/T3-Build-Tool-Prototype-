# set your directory below to where you saved the two .scv files from the repo. 

setwd("C:/Users/Ray/EveData/T3")
library("XML")
library("dplyr")

# Getting shit
#url <- "http://api.eve-central.com/api/marketstat?typeid=30466&usesystem=30000142"

typefile <- "C:/Users/Ray/EveData/T3/typelist.csv"
prices <- NULL
typelist <- read.csv(typefile)
types <- as.list(typelist[,1])

getTypeId <- function(typeid) {
        type <- as.character(typeid)
        system <- "30000142"
        initstr <- "http://api.eve-central.com/api/marketstat?typeid="
        endstr <- "&usesystem="
        url <- paste(c(initstr,type,endstr,system), sep = "", collapse = "")
        data <- xmlParse(url)
        xmldata <- xmlToList(data)
        out <- data.frame(xmldata, stringsAsFactors = FALSE)
        final <- out[1,]
        prices <<- rbind(prices, final)
        }

lapply(types,getTypeId)

# Tier one build costing stuffs

tierone <- "C:/Users/Ray/EveData/T3/tierone.csv"
primary <- read.csv(tierone)

primary$buildcost <- 0
asd <- c("marketstat.type..attrs", "marketstat.type.sell.percentile","marketstat.type.sell.volume","marketstat.type.buy.volume")
pricesimple <- subset(prices, select = asd)
pnames <- c("typeID","sellpercent","sellVol","buyVol")
colnames(pricesimple) <- pnames

# Merge in "tier one" build prices - Building just from the first level down of sold mats.
mp <- merge(x = primary, y=pricesimple, by.x = "materialTypeID", by.y="typeID", all.x=TRUE )
mp$buildcost <- mp$matQty * as.numeric(mp$sellpercent) / mp$quantity

# Aggregate by typeID
mpagg <- aggregate(mp$buildcost, by=list(category=mp$typeID), FUN=sum)
colnames(mpagg) <- c("typeID","cost")
mpaggm <- merge(x = mpagg, y = pricesimple, by = "typeID", all.x = TRUE)

# Caluclate Profit
mpaggm$profit <- as.numeric(mpaggm$sellpercent) - mpaggm$cost
fnames <- typelist[,1:2]
profit <- merge(mpaggm, fnames, by = "typeID", all.x=TRUE)
profit$margin <- profit$profit / profit$cost * 100

# Raw Isk Profit
rawprofit <- arrange(profit, desc(profit))

# Margin over build ocst profit
marginprofit <- arrange(profit, desc(margin))

head(rawprofit, 10)
head(marginprofit, 10)





