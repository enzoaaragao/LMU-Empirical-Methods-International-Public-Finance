# Object types in R:
my_scalar <- "c"
my_scalar2 <- 1

my_vector <- c(1, 2, 3) # this is numeric
my_vector <- c(1:3) # this is integer
my_vector2 <- c(1:3, "a", "b")  # this is characters
my_vector3 <- c("a", "b", "c") # this is characters

my_matrix <- matrix(c(1, 3, 5, 2, 6, 4, 4, 2, 3, 10), ncol = 2) # numeric
my_matrix2 <- matrix(1:10, nrow = 2) # integer
my_matrix3 <- matrix(c(1:10, "a", "b"), nrow = 2) # characters

my_dataframe <- data.frame(Var1 = c("a", "b", "c"), 
                           Var2 = c(1:3))

plot(my_vector)
plot(my_matrix, type = "l") # the type indicates the style of the graph, try without it
hist(my_matrix)

help("ggplot2")

# basic syntax:
data <- iris
plot(data$Sepal.Length, data$Sepal.Width) # esse $ serve para que?

# easy to do more complicated things
ggplot(data, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) + geom_point()
  # geom_point is most useful to make scatterplots
# this is possible in normal plots, too, but ggplot makes it really simple

# +---------------+
# | ZUCMAN GRAPHS |
# +---------------+

data_z13 <- read.csv("ZucmanData.csv")

# straightforward:
ggplot(data_z13, aes(x = year, y = value)) + geom_point()

ggplot(data_z13, aes(x = year, y = value)) + geom_line()

  # by group
ggplot(data_z13, aes(x = year, y = value, group = type)) + geom_line()

ggplot(data_z13, aes(x = year, y = value, group = type, color = type)) + geom_line()

ggplot(data_z13, aes(x = year, y = value, group = type, color = type))+
  geom_line() + 
  geom_point()

ggplot(data_z13, aes(x = year, y = value, group = type, fill = type))+
  geom_bar(stat = "identity")

ggplot(data_z13, aes(x = year, y = value, group = type, fill = type))+
  geom_bar(stat = "identity", position = position_dodge())

# now we need to create the secondary axis:
str(data_z13) # to display the structure of an object in R
#help("str")

data_z13[data_z13$type == "Discrepancy", "value"] <- data_z13[data_z13$type == "Discrepancy", "value"] * 10
# I just multiplied the values related to "Discrepancy" by 10

# to change the values of a colum I can also use the operator ":=" (colon equals)
##data_z13[type == "Discrepancy", value := value*10]


primarydata <- data_z13[!data_z13$type == "Discrepancy",] # "!" tudo que nao seja "Discrepancy"
secondarydata <- data_z13[data_z13$type == "Discrepancy",] # tudo que seja "Discrepancy"

pdf("./myfile.pdf",
    width = 6, height = 4)
ggplot(primarydata, aes(x = year, y = value, group = type, fill = type))+
  geom_bar(stat="identity", position=position_dodge()) +
  xlab("")+
  ylab("Billions of current U.S. dollars") + 
  scale_fill_manual(values = c("white", "lightgrey", "darkgrey"))+
  geom_line(data = secondarydata, aes(x = year, y = value)) +
  geom_point(data = secondarydata, aes(x = year, y = value), shape =24, size = 4) +
  scale_y_continuous(sec.axis = sec_axis(~ . /10)) + # this is for another scale on the right side of the graph 
  guides(fill=FALSE) + 
  theme_bw()
dev.off()



