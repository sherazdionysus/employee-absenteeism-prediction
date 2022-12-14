#get working directory
getwd()


#load the libraries

library(corrplot)
library(ggplot2)
library(dplyr)
library(readr)
library(readxl)
library(leaps)
library(ISLR2)
library(glmnet)
install.packages('el1071')
library(e1071)
library(caret)
#read the data

data <- read_excel("Absenteeism_at_work.xls")


#summary
summary(data)

#rename the colummns  
colnames(data)[colnames(data) == "Reason for absence"] <- "reason_for_absence"
colnames(data)[colnames(data) == "Month of absence"] <- "month_of_absence"
colnames(data)[colnames(data) == "Day of the week"] <- "day_of_week"
colnames(data)[colnames(data) == "Transportation expense"] <- "transport_expense"
colnames(data)[colnames(data) == "Distance from Residence to Work"] <- "distance_residence_work"
colnames(data)[colnames(data) == "Service time"] <- "service_time"
colnames(data)[colnames(data) == "Work load Average/day"] <- "avg_workload_day"
colnames(data)[colnames(data) == "Hit target"] <- "hit_target"
colnames(data)[colnames(data) == "Disciplinary failure"] <- "disciplinary_fail"
colnames(data)[colnames(data) == "Social drinker"] <- "social_drinker"
colnames(data)[colnames(data) == "Social smoker"] <- "social_smoker"
colnames(data)[colnames(data) == "Body mass index"] <- "BMI"
colnames(data)[colnames(data) == "Absenteeism time in hours"] <- "Absenteeism_time"

summary(data)

#convert factor variables to type factor

data$reason_for_absence <- as.factor(data$reason_for_absence)
data$month_of_absence <- as.factor(data$month_of_absence)
data$day_of_week <- as.factor(data$day_of_week)
data$Seasons <- as.factor(data$Seasons)
data$disciplinary_fail <- as.factor(data$disciplinary_fail)
data$Education <- as.factor(data$Education)
data$social_drinker <- as.factor(data$social_drinker)
data$social_smoker <- as.factor(data$social_smoker)
data$Pet <- as.factor(data$Pet) #coding number of  pets as a factor as well
data$Son <- as.factor(data$Son)

#outcome variable has absenteeism time in hour with mean of 6.924. We are gonnna divide the absenteeism between normal/abnomral keeping 6 hour as the limit for normal

data$absent_type <- factor(ifelse(data$Absenteeism_time > 6, "Abnormal", "Normal"))


summary(data)


#look for missing values
#no missing values found in the data
sum(colnames(is.na))

missingValueCheck <- function(data)
{
  for (i in colnames(data))
  {
    print(i)
    print(sum(is.na(data[i])))
  }
  print("Total")
  print(sum(is.na(data)))
}
missingValueCheck(data)

###### EXPLORATORY ANALYSIS #####


#percentage of normal and abnormal absents
#37% of total absents are abnormal
absentplot <- data %>% group_by(absent_type) %>%
  count() %>% ungroup() %>% mutate(perc = `n`/sum(`n`)) %>%
  arrange(perc) %>%
  mutate(labels = scales::percent(perc))


summary(absentplot)
table(absentplot)

ggplot(data = absentplot, aes(x = "", y = perc, fill = absent_type)) +
  geom_col() +
  geom_text(aes(label = labels), position = position_stack(vjust = 0.5), show.legend = TRUE) +
  coord_polar(theta = "y") +
  theme_void()



#outliers analysis to remove any unusual values

#for factors
boxplot(data$reason_for_absence) #no outlier noted
boxplot(data$month_of_absence) #no outlier noted
boxplot(data$day_of_week) # no outlier noted
boxplot(data$Seasons) #no outlier noted
boxplot(data$service_time)


boxplot(data$Education)
table(data$Education) # most of the people are educated till high school but we will keep these in the data

boxplot(data$disciplinary_fail)
boxplot(data$Pet)
table(data$Pet)
#for numeric variables
hist(data$transport_expense)
hist(data$distance_residence_work)
hist(data$service_time, labels = TRUE) #few outliers detected
hist(data$Age, labels = TRUE)
hist(data$avg_workload_day, labels = TRUE)
hist(data$hit_target, labels = TRUE)
hist(data$Son)







#dropping the absenteeism time column 

summary(modeldata)

modeldata <- subset(data, select = -c(Absenteeism_time))

#### MODEL Building

set.seed(1992)

index <- createDataPartition(modeldata$absent_type, p = 0.8, list = FALSE, times=1) 

train <- modeldata[index,] #index reference by rows

test <- modeldata[-index,]





#### Specify and train Lasso Regression model

ctrlspecLASSO <- trainControl(method="cv", number = 10,
                              savePredictions = "all",
                              summaryFunction = twoClassSummary,
                              classProbs = TRUE)


#create a vector for lambda values

lambda_vector <- 10^seq(5, -5, length=500)

#setseed
set.seed(1992)

#Specify the Lasso  regression model using training data and 10 fold cross validation



model1 <- train(absent_type ~ .,
                data = train,
                preProcess=c("center", "scale"),#preprocess the predictor variable to scale them 
                method="glmnet",
                    metric = "ROC",
                    tuneGrid=expand.grid(alpha=1, lambda = lambda_vector),
                trControl=ctrlspecLASSO, na.action=na.omit,
                family = "binomial") #train control to specify our 10 fold cross validation function 

model1$bestTune$lambda

round(coef(model1$finalModel, model1$bestTune$lambda), 3)

print(model1)


plot(log(model1$results$lambda), 
     model1$results$ROC,
     xlab = "log lambda",
     ylab = "ROC",
     xlim = c(1,20),
     ylim = c(0.0, 1))

#variable importance
varImp(model1)
plot(varImp(model1))

install.packages("vip")
library(vip)



ggplot(varImp(model1), top = 20)



####predicting the performance
predictionlasso <- predict(model1, newdata=test)

plot(x=predictionlasso, y=test$absent_type)
abline(a=0, b=1)


# Model Performance/Accuracy

confusionMatrix(predictionlasso, test$absent_type)








######RANDOM FOREST####################
set.seed(1992) 
ctrlspecRF <- trainControl(method="cv", number = 10,
                         search = "random",
                         savePredictions = T) 

#applying a random forest model

randomforest <- train(absent_type ~ ., 
                      data = train,
                      method = "rf",
                      trControl = ctrlspecRF, tuneLength = 10, 
                      ntree=1000)

print(randomforest)

randomforest$bestTune

plot(randomforest)
plot(varImp(randomforest, scale = F), main = "Variable importance for RF")

#model prediction

rfprediction <- predict(randomforest, newdata = test)

confusionMatrix(rfprediction, test$absent_type)


#applying a random forest model with more number of trees


randomforest2 <- train(absent_type ~ ., 
                      data = train,
                      method = "rf",
                      trControl = ctrlspecRF, tuneLength = 17, 
                      ntree=5000)




randomforest2$bestTune


plot(varImp(randomforest, scale = F), main = "Variable importance for RF")

#model prediction

rfprediction2 <- predict(randomforest2, newdata = test)

confusionMatrix(rfprediction2, test$absent_type)


#random forest model with grid search after specifying tuning grid with repeated 10 fold CV

controlRFgridsearch <- trainControl(method = 'repeatedcv',
                                    number = 10,
                                    repeats = 3,
                                    search = 'grid'
                                      )

tunegrid_rf <- expand.grid(.mtry = (1:30))

rf_grid <- train(absent_type ~ ., 
                 data = train,
                 method = "rf",
                 tuneGrid = tunegrid_rf,
                 trControl = controlRFgridsearch)

print(rf_grid)

rf_grid$bestTune

plot(rf_grid)

varImp(rf_grid)

  #model prediction

rfgridpred<- predict(rf_grid, newdata = test)

confusionMatrix(rfgridpred, test$absent_type) #best mode






#################SUPPORT VECTOR MACHINES##################

svm <- svm(formula = absent_type ~ ., 
           data = train,
           type = 'C-classification',
           kernel = 'linear')
print(svm)


svmpred <- predict(svm, newdata = test)

confusionMatrix(svmpred, test$absent_type) #best mode



#svm using random search

set.seed(1992)

#specify the control function for random search
controlsvmrandom <- trainControl(method = 'cv',
                                    number = 10,
                                    search = 'random',
                                 savePredictions = TRUE)


#specify SVM model

svmrandom <- train(absent_type ~ .,
                   data = train,
                   method = "svmRadialSigma",
                   trControl = controlsvmrandom,
                   tuneLength = 20)

svmrandom$bestTune #values of signma for the best model as per random search is 0.0000008190721 and c is 0.04


svmpredrandom <- predict(svmrandom, newdata = test)

confusionMatrix(svmpredrandom, test$absent_type)



#SVM using grid search 

controlsvmgrid <- trainControl(method = 'cv',
                               number = 10,
                               savePredictions = TRUE)

tuneGridsvm=expand.grid(
  .sigma=seq(0.0000000000491661, 0.0000000000120000, length = 20),
  .C=seq(0.01, 0.06, length = 20))


svmgrid <- train(absent_type ~ ., 
                 data = train,
                 method = "svmRadialSigma",
                 trControl = controlsvmgrid,
                 tuneGrid = tuneGridsvm)

svmpred <- predict(svmgrid, newdata = test)

confusionMatrix(svmpred, test$absent_type) #best mode

varImp(svmgrid)



######gradient boosted tree#


#xg boost tuning grid

xgboosttune <- expand.grid(nrounds=c(500,1000,1500),
                                      eta = c(0.01,0.05),
                                      max_depth = c(2,4,6),
                                      colsample_bytree = c(0.5,1),
                                      subsample = c(0.5,1),
                                      gamma = c(0,50),
                                      min_child_weight = c(0,20))

control_xgb <- trainControl(method = "cv",
                             number=10, #folds of cross validation
                             verboseIter = TRUE,
                            allowParallel = TRUE)




xgb <- train(absent_type ~ ., 
             data = train,
             method = "xgbTree",
             trControl = control_xgb,
             tuneGrid = xgboosttune,
             verbose = TRUE)

predictxgb <- predict(xgb, newdata = test)
confusionMatrix(predictxgb, test$absent_type) #best model



varImp(xgb)
plot(predictxgb)



#### DECISION TREE MODEL###   

install.packages("rattle")
library(rattle)
library(caret)

ctrlDT <- trainControl(method = "cv", #cross validation
                       number = 10)   #10-fold cross validation

grid_DT <- data.frame(cp = seq(0.02, .2, .02))

modelDT <- train(absent_type~., data = train, method = 'rpart',
                 trControl = ctrlDT,      
                 tuneGrid = grid_DT)


modelDT


#plot dt
fancyRpartPlot(modelDT$finalModel, sub = NULL)


#predictive performance
predictDT <- predict(modelDT, newdata = test)
confusionMatrix(predictDT, test$absent_type)

varImp(modelDT)

