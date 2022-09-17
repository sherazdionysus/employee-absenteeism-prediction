# employee-absenteeism-prediction
Predicting Employee Absenteeism using Machine Learning in R
This project was done as part of the MSc Business Analytics program at Queen's University Belfast for the year 2021/22


This research analysed the probability of employees committing abnormal absents on Brazilian Courier Company data set. The best predictor of abnormal absences is found to be decision tree model. This result differs with previous researchers who found performance of other algorithms better than decision trees. This could be due to the difference of tuning parameters employed. Wahid et al. (2019) found the accuracy of 82% using Gradient Boosted, 80.4% for Random forest and 79% with Tree Ensemble and decision trees.  We found accuracy of 82% using LASSO logistic regression, XG boost and decision tree, and 80.9% for Random Forest. This shows that using grid search and 10-fold cross validation has yielded better predictive performance for most models. 

Nath et al. (2022) who analysed the same data set got predictive Accuracy of 93.2% on MLR, 88.7% on SVM and 86.9% on random forest. This shows that it is possible to achieve the predictive accuracy score of more than what we reported on the same data set and our models have further room for improvement. 


Wahid et al. (2019) analysed the same data set from a Brazilian Courier Company and applied Gradient Boosted Trees, Random Forest, Tree Ensemble and Decision Tree algorithms. They used 7 evaluation metrics such as Sensitivity, Specificity, Accuracy, True Positive, True Negative, False Positive and False Negative to measure the predictive performance of the algorithms. They reported predictive accuracy of 82% using Gradient Boosted Trees and 79% with Tree Ensemble. 

This study noted medical reasons for absences, average workload/day, disciplinary failure, BMI, service time, transport expense, education level and distance from residence to work alongside other specified the results above as the most important predictors of abnormal absences. This information could be used by employees to control the abnormal absenteeism among their workforce. As discussed earlier, the abnormal absenteeism results in added cost and reduced benefit to an organization and controlling abnormal absenteeism is one of the main objectives of HRM. This study can be used by HRM professionals to understand the factors impacting abnormal absenteeism and take actions accordingly. 

Although, this research has been done on a Brazilian data set, similar circumstances exist all across the globe (Ali Shah et al., 2020). The same models could also be trained on the local data set of any other geographical location in order to predict the abnormal absenteeism. This research adds to the growing literature on predicting employing absenteeism. The findings could be used by Human Resource Specialist and higher management of organizations in order to mitigate the factors impacting abnormal absenteeism. Kocakulah et al. (2016) suggested various measures that could be adapted in order to decrease abnormal absences. Keeping in view the important predictors proposed in this study, it is suggested that organizations could take following measures to address the issue (Kocakulah et al., 2016):

1.	Creation of positive company culture
2.	Increased work life balance and decreased workload for employees. 
3.	Medical assistance and employee assistantship programs.
4.	Childcare and flexible scheduling

![image](https://user-images.githubusercontent.com/113776928/190857636-a28bc030-460b-4b42-a293-389d84f8506d.png)
