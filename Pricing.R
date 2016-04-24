# Declare your directory and files here.  You also declare your system for 
#  market prices and build indices

directory <- "C:/Users/Ray/EveData/T3"
typeIDList <-"typelist.csv"
buildReqsList <- "tierone.csv"
marketSystem <- "30000142" # Market Prices, currently Jita
buildSystem <- "Paara"     # Indices for builds

# Declare some things needed later that might need updating
CRESTurl <- "https://public-crest.eveonline.com/market/prices/"
eveIndURL <- "http://api.eve-industry.org/system-cost-index.xml?name="

# Import needed files
setwd(directory)
typefile <- paste(directory,typeIDList, sep = "/")
tierone <- paste(directory,buildReqsList, sep = "/")

# Load required packages
library("XML")
library("dplyr")
library("jsonlite")

# Getting prices from the Eve-Central API
#   url <- "http://api.eve-central.com/api/marketstat?typeid=30466&usesystem=30000142"

prices <- NULL
typelist <- read.csv(typefile)
types <- as.list(typelist[,1])

getTypeId <- function(typeid) {
        type <- as.character(typeid)
        system <- marketSystem # This is Jita
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

# Get a list of the adjusted Prices from the CREST API
getCRESTadjPrice <- function() {
        rawPrices <- fromJSON(CRESTurl, simplifyDataFrame = TRUE)
        a <- data.frame(rawPrices)
        b <- a[,c(2,4)]
        c <- as.data.frame.table(b)
        d <- c[,c(6,7,3,5)]
        adjPrice <- unique(d)
        rm(a,b,c,d)
        colnames(adjPrice) <- c("typeID","typeName","adjustedPrice","CRESThref")
        adjPrice <<- adjPrice
}

getCRESTadjPrice()

adjPrice <- adjPrice[,c(1,3)]

# Get System indices from eve-industry.org

sysAPIurl <- paste(eveIndURL,buildSystem, sep = '')
sysCost1 <- xmlParse(sysAPIurl)
sysCostData <- xmlToList(sysCost1)

indices <- data.frame(system = character(),
                      systemID = integer(),
                      manufacturing = numeric(),
                      TE = numeric(),
                      ME = numeric(),
                      copy = numeric(),
                      revEng = numeric(),
                      inv= numeric(),
                      stringsAsFactors = FALSE)
indices[1,1] <- sysCostData[[1]][[7]][[2]]
indices[1,2] <- as.numeric(sysCostData[[1]][[7]][[1]])
indices[1,3] <- as.numeric(sysCostData[[1]][[1]][[1]])
indices[1,4] <- as.numeric(sysCostData[[1]][[2]][[1]])
indices[1,5] <- as.numeric(sysCostData[[1]][[3]][[1]])
indices[1,6] <- as.numeric(sysCostData[[1]][[4]][[1]])
indices[1,7] <- as.numeric(sysCostData[[1]][[5]][[1]])
indices[1,8] <- as.numeric(sysCostData[[1]][[6]][[1]])

# Tier one build costing stuffs
primary <- read.csv(tierone)
primary$buildcost <- 0
uglyNames <- c("marketstat.type..attrs","marketstat.type.sell.percentile","marketstat.type.buy.percentile","marketstat.type.sell.volume","marketstat.type.buy.volume")
pricesimple <- subset(prices, select = uglyNames)
prettyNames <- c("typeID","sellPercent","buyPrecent","sellVol","buyVol")
colnames(pricesimple) <- prettyNames

# Merge in "tier one" build prices - Building just from the first level down of sold mats.
mp <- merge(x = primary, y=pricesimple, by.x = "materialTypeID", by.y="typeID", all.x=TRUE )
mp <- merge(x= mp, y = adjPrice, by.x = "materialTypeID", by.y="typeID", all.x = TRUE)
mp$materialCost <- mp$matQty * as.numeric(mp$sellPercent) / mp$quantity
mp$jobFee <- mp$matQty * mp$adjustedPrice * indices[1,3]
mp$fullCost <- mp$materialCost + mp$jobFee

# Aggregate by typeID
mpagg <- aggregate(mp$fullCost, by=list(category=mp$typeID), FUN=sum)
colnames(mpagg) <- c("typeID","cost")
mpaggm <- merge(x = mpagg, y = pricesimple, by = "typeID", all.x = TRUE)

# Caluclate Profit
mpaggm$profit <- as.numeric(mpaggm$sellPercent) - mpaggm$cost

# Add names
fnames <- typelist[,1:2]
profit <- merge(mpaggm, fnames, by = "typeID", all.x=TRUE)
profit$margin <- profit$profit / profit$cost 
profit <- profit[,c(8,1,7,9,5,6,2,3,4)]
# Raw Isk Profit
rawprofit <- arrange(profit, desc(profit))

# Margin over build ocst profit
marginprofit <- arrange(profit, desc(margin))

head(rawprofit, 10)
head(marginprofit, 10)





