library(maps)
library(maptools)
library(mapdata)
library(scales)

map("worldHires", "India",
	col = "gray",
	fill = TRUE)

nameFolder = paste(getwd(), "pinucont", sep="/")
root = "C:/Documents and Settings/ssbhat3/Desktop/Org Docs/MonResCen"
nameFolder = paste(root, "pinucont", sep="/")
nameShape = paste(nameFolder, "pinucont.shp", sep="/")
namePoints = paste(nameFolder, "FieldSamples.csv", sep="/")

s <- readShapePoly(nameShape) 
p <- read.csv(namePoints)

map("worldHires", "Canada",
	col = "gray90",
	xlim = c(-140, -110),
	ylim = c(48, 64),
	fill = TRUE)
map("worldHires", "usa",
	col = "gray95",
	fill = TRUE,
	add = TRUE)
plot(s, col = "darkgreen",
		border = FALSE,
		add = TRUE)

urls <- c(
    "http://stat.ethz.ch/R-manual/R-devel/library/base/html/connections.html",
    "http://en.wikipedia.org/wiki/Xz",
    "xxxxx"
)

u <- readUrl(urls[2]);

readUrl <- function(url) {
    out <- tryCatch(
        {
            # Just to highlight: if you want to use more than one 
            # R expression in the "try" part then you'll have to 
            # use curly brackets.
            # 'tryCatch()' will return the last evaluated expression 
            # in case the "try" part was completed successfully

            message("This is the 'try' part")

            o <- readLines(con=url, warn=FALSE) 
            # The return value of `readLines()` is the actual value 
            # that will be returned in case there is no condition 
            # (e.g. warning or error). 
            # You don't need to state the return value via `return()` as code 
            # in the "try" part is not wrapped insided a function (unlike that
            # for the condition handlers for warnings and error below)
        },
        error=function(cond) {
            message(paste("URL does not seem to exist:", url))
            message("Here's the original error message:")
            message(cond)
            # Choose a return value in case of error
            return(NA)
        },
        warning=function(cond) {
            message(paste("URL caused a warning:", url))
            message("Here's the original warning message:")
            message(cond)
            # Choose a return value in case of warning
            return(o)
        },
        finally={
        # NOTE:
        # Here goes everything that should be executed at the end,
        # regardless of success or error.
        # If you want more than one expression to be executed, then you 
        # need to wrap them in curly brackets ({...}); otherwise you could
        # just have written 'finally=<expression>' 
            message(paste("Processed URL:", url))
            message("Some other message at the end")
        }
    )    
    return(out)
}