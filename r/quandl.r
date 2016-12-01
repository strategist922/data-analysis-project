library(devtools)
install_github('quandl/quandl-r') 
library(Quandl)

data <- Quandl("WIKI/DOW", start_date="2016-11-08", end_date="2016-11-27")

summary(data)
plot(data$Date, data$Close, type = "o", col = "red", xlab = "Month", ylab = "Closing Price",
     main = "DOW JONES Closing Price")
