#Height and crown volume estimates from dbh
#Hanno Southam, 18 Jun 2024

#load packages
library(tidyverse)
library(nlme)

#read in tree data
trees <- read_csv("./data/workflow/trees_mapped.csv")
summary(trees)

#remove trees without height values
trees_ht <- trees %>% filter(!is.na(height_m))

#plot height vs dbh
ggplot(trees_ht, aes(x=dbh, y=height_m, color=site_id)) + geom_point()

#add dbh^2 to the dataset so it can be modeled as its own variable
trees_ht <- trees_ht %>% mutate(dbh2 = dbh^2)

#Following the curve fitting procedure in: https://www2.gov.bc.ca/assets/gov/farming-natural-resources-and-industry/forestry/timber-pricing/timber-cruising/cruise-compilation-manual/2020_cruise_comp_amend_2_master_c.pdf 

#Model 1: Parabola
## Fit linear mixed effect model, random effect = site
m1 <- lme(height_m ~ dbh + dbh2, data = trees_ht, method="REML", 
          random=~1|site_id)
 

#Store the predicted values and the residuals
trees_ht$yhat.m1.0 <- fitted(m1,level=0)  # estimated population averaged yhats
trees_ht$yhat.m1.1 <- fitted(m1,level=1)  # estimated level=1 subject-specific yhats
trees_ht$resid.m1.0 <- resid(m1,level=0)  # estimated population averaged residual
trees_ht$resid.m1.1 <- resid(m1,level=1)  # estimated level=1 subject-specific residual

#Population averaged fitted-line plot
plot(trees_ht$height_m, trees_ht$yhat.m1.0, main="Model 1, Population-Averaged 
  Fitted Line Plot", ylab="yhat", xlab="height_m")
abline(a=0, b=1, col="red")

#Subject (site) specific fitted-line plot
plot(trees_ht$height_m, trees_ht$yhat.m1.1, main="Model 1, Subject-Specific
  Fitted Line Plot", ylab="yhat", xlab="height_m")
abline(a=0, b=1, col="red")

#Residuals plot
##Assessment: looks pretty good
plot(trees_ht$yhat.m1.1, trees_ht$resid.m1.1, 
     main="Model 1, Residuals Plot",xlab="yhat", ylab="residual")
abline(h=0, col="red")

#QQ plot
##Assessment: skew on lower tail
qqnorm(trees_ht$yhat.m1.1, main="Model 1, QQ Plot")
qqline(trees_ht$yhat.m1.1, col="red")

#Histogram
##Assessment: looks okay 
hist(trees_ht$resid.m1.1, breaks =8 , density=10,col="green", border="black",
     main="Model 1, Residuals Distribution")
par(mfrow=c(1,1),mai=c(1.0,1.0,1.0,1.0),cex=1.0)

#Get model coefficients
##One of rules from Ministry handbook: "If the b and c coefficients are positive for the Parabola, the Weibull function must not be used". Not the case here (dbh coef >0 and dbh2 < 0).
##Random effect justified. Standard deviation of the errors is reported under "Random effects". Square this to get variance of errors. Intercept = variance of the errors from the randome effect (site); Residual = variance of the errors leftover. These are similar --> the randome effect is sucking up a significant amount of error. 
summary(m1)

#Find minimum dbh we can predict height for
##Store model coefficients
coef.m1 <- m1$coefficients$fixed
##Use given equations to predict minimum. Square root in equation can be posiive or negative, take the one closest to 0.
##Min = 4.58
dbh.min.m1.1 <- (-coef.m1[2] + (coef.m1[2]^2 - 
                                (4*coef.m1[1]*coef.m1[3]))^(1/2))/(2*coef.m1[3])
dbh.min.m1.2 <- (-coef.m1[2] - (coef.m1[2]^2 - 
                                  (4*coef.m1[1]*coef.m1[3]))^(1/2))/(2*coef.m1[3])

#Find maximum dbh we can predict height for
##Max = 86.46
dbh.max.m1 <- -coef.m1[2]/(2*coef.m1[3])


