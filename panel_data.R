library("data.table")

# 1. load data
load("./Data_BIS_ForClass.RData")

# 2. check structure
str(Data)
Data[countrypair == "Belgium.Australia"]

unique(Data[, country])
unique(Data[, counterparty])
unique(Data[, time])

# 3. Plot (with a line, not dots) the liabilities that Irish banks report against German non-bank
# counterparties using plot() and ggplot().
library("ggplot2")

Data[country == "Ireland" & counterparty == "Germany", lbs.l.all.nonbanks] #data I want to plot

plot(y = Data[country == "Ireland" & counterparty == "Germany", lbs.l.all.nonbanks], 
     x =Data[country == "Ireland" & counterparty == "Germany", time],
     type = "l")

ggplot(data = Data[country == "Ireland" & counterparty == "Germany"],
       aes(x = time, y = lbs.l.all.nonbanks)) +
    geom_line()

# Don't know how to automatically pick scale for object of type yearqtr. Defaulting to continuous.
install.packages("zoo")
library("zoo")
# Now run the ggplot again


# 4.Regress, using lm(), the natural logarithm of the variable measuring non-bank liabilities on
# a constant, the treaty dummy and variables measuring the landlines, population and gdp of
# the counterparty. Do the same using plm().

?lm()
my_lm_test <- lm(log(lbs.l.all.nonbanks) ~ treaty.signed + landlinesp100_cparty + gdp_cparty + pop_cparty,
   data = Data) # to get rid of the constant just type -1 at the beginning
summary(my_lm_test) # pay attention, you just created a new object, see below
my_lm_test["coefficients"]

?plm()
install.packages("plm")
library("plm")

my_plm_test <- plm(log(lbs.l.all.nonbanks) ~ 1 + treaty.signed + landlinesp100_cparty + gdp_cparty + pop_cparty,
    data = Data,
    model = "pooling")

summary(my_lm_test)
summary(my_plm_test)
# I get the same results because I have not transformed the data for plm yet


# 5. Calculate the vector of OLS coefficients without using functions of the same regression (use
# "%*%").

mymatrix <- matrix(1:16, ncol = 4)
mymatrix2 <- matrix(c(rep(2,12), rep(4,4)), ncol = 4)

mymatrix*5 # R multiplies it element by element
mymatrix %*% mymatrix2

# betahat = (X'X)^-1 X'y
y <- log(Data[, lbs.l.all.nonbanks])
str(y)

X <- Data[, .(treaty.signed, landlinesp100_cparty,  gdp_cparty,  pop_cparty) ]
# it is missing the constant
X <- as.matrix(cbind(1, X))

# Transpose of X
?t()

# Inverse
?solve()

# OLS Formula
solve(t(X) %*% X) %*% t(X) %*% y


# 6. Perform a within-transformation of the series "lbs.l.all.nonbanks", the dummy "treaty.signed",
# and the three macroeconomic variables using the countrypair variable. Don't overwrite the
# old variable names.

Data[, logliabs := log(lbs.l.all.nonbanks)]

Data[, liabs_within := logliabs - mean(logliabs), by = countrypair]
Data[, gdp_within := gdp_cparty - mean(gdp_cparty, na.rm = T), by = countrypair]
# by default, R would not eliminate the NAs
Data[, pop_within := pop_cparty - mean(pop_cparty, na.rm = T), by = countrypair]
Data[, landlines_within := landlinesp100_cparty - mean(landlinesp100_cparty, na.rm = T), by = countrypair]
Data[, treaty_within := treaty.signed - mean(treaty.signed, na.rm = T), by = countrypair]


# 7. Calculate the vector of OLS coefficients of the within transformed data without using functions.
y <- Data[, liabs_within]
X <- as.matrix(Data[, .(treaty_within, landlines_within,  gdp_within,  pop_within) ])

solve(t(X) %*% X) %*% t(X) %*% y


#8. Create the same result using lm().
my_lm_test_within <- lm(liabs_within ~ -1 + treaty_within + landlines_within + gdp_within + pop_within,
                 data = Data) # to get rid of the constant just type -1 at the beginning
summary(my_lm_test_within)

# extra, without the within and using the plm
my_plm_fe <- plm(log(lbs.l.all.nonbanks) ~ treaty.signed + landlinesp100_cparty + gdp_cparty + pop_cparty,
                 data = Data,
                 index = c("countrypair", "time"),
                 model = "within")
summary(my_plm_fe)

# extra extra, using a dummy for countrypair
my_lm_test_dummy <- lm(log(lbs.l.all.nonbanks) ~ -1 + treaty.signed + landlinesp100_cparty + gdp_cparty + pop_cparty + as.factor(countrypair),
                 data = Data)
summary(my_lm_test_dummy)


# 9.& 10.Plot (with lines) the liabilities that Irish banks report against 5 counterparties of your choice.

unique(Data[country == "Ireland", counterparty])
my_counterparties <- c("Australia", "Sweden", "Denmark", "Greece", "Japan")
my_counterparties[!my_counterparties %in% unique(Data[country == "Ireland", counterparty])]

Data[country == "Ireland" & counterparty %in% my_counterparties]

ggplot(data = Data[country == "Ireland" & counterparty %in% my_counterparties],
       aes(x = as.numeric(time), y = lbs.l.all.nonbanks, group = counterparty, color = counterparty)) +
  geom_line()+
  xlab("Year")+
  ylab("Ireland liabilities in all nonbanks in thousands of U.S. Dollars")
