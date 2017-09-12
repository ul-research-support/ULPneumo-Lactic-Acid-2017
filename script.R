##########################################################################
### Step 1: Read in the data and factor variables
##########################################################################
lactate<-read.csv("~/Desktop/Test/Test/lactate.csv", stringsAsFactors = FALSE)

##########################################################################
### Step 2: Factoring Variables
##########################################################################
factor_vars<-names(lactate)[-c(2,29,32,34)]
lactate[factor_vars]<-lapply(lactate[factor_vars], factor)
lactate$sex<-factor(lactate$sex,levels=c(0,1),labels=c("Female","Male"))
lactate$lactate<-factor(lactate$lactate,levels=c(0,1,2),labels=c("Normal","Elevated","Very High"))

##########################################################################
### Step 3: Table 1
##########################################################################
library(tableone) # must run this line for the next line to work!
table1<-CreateTableOne(vars=names(lactate),
                       data=lactate,
                       factorVars=factor_vars
                       ,strata="lactate"
)
print("Table 1. Patient Characteristics")
print(table1,quote=F,noSpaces=T)

##########################################################################
### Step 4: Univariate Analysis
##########################################################################
model_vars<-c("lactate","copd","icudirect","imv","vaso","diabetes","sex","psi4or5","curb4or5")
univariate_summary<-lapply(seq_along(lactate[model_vars]),
                      y=lactate[model_vars],
                      function(i,y){
                        model<-glm(lactate$ihm ~ factor(y[[i]],ordered=F),
                                   family="binomial")
                        cbind(exp(coefficients(model)),
                              exp(confint(model)),
                              round(summary(model)$coefficients[,4],3))[-1,]
                      })

univariate_summary<-do.call(rbind,univariate_summary)
row.names(univariate_summary)<-c("2-4 mmol/L",">=4 mmol/L",
                            "COPD","ICU Admission Day 0", "IMV Day 0",
                            "Vasopressors Day 0","Diabetes","Sex",
                            "PSI Risk Class 4 or 5","Curb65 4 or 5")

univariate_summary[,1:3]<-round(univariate_summary[,1:3],2)
univariate_summary<-cbind(univariate_summary[,1],paste0("(",univariate_summary[,2],", ",univariate_summary[,3],")"),univariate_summary[,4])
colnames(univariate_summary)<-c("Odds Ratio","95% CI","P-value")
univariate_summary[,3]<-ifelse(univariate_summary[,3]==0,"<0.001",univariate_summary[,3])
print("Table 2a. Single Predictor Model Summaries")
print(univariate_summary,quote=F)

##########################################################################
### Step 4: Multivariate Analysis
##########################################################################
multivariate_model<-glm(ihm ~ lactate + icudirect + imv + vaso + psi4or5,
           data=lactate,
           family="binomial")

multivariate_summary<-cbind(exp(coefficients(multivariate_model)),exp(confint(multivariate_model)),round(summary(multivariate_model)$coefficients[,4],3))
multivariate_summary[,1:3]<-round(multivariate_summary[,1:3],2)
multivariate_summary<-cbind(multivariate_summary[,1],paste0("(",multivariate_summary[,2],", ",multivariate_summary[,3],")"),multivariate_summary[,4])
multivariate_summary[,3]<-ifelse(multivariate_summary[,3]==0,"<0.001",multivariate_summary[,3])
multivariate_summary<-multivariate_summary[-1,]
colnames(multivariate_summary)<-c("Odds Ratio","95% CI","P-value")
row.names(multivariate_summary)<-c("2-4 mmol/L",">=4 mmol/L",
                                   "ICU Admission Day 0", "IMV Day 0",
                                   "Vasopressors Day 0","PSI Risk Class 4 or 5")
print("Table 2b. Multiple predictors Model Summary")
print(multivariate_summary,quote=F)
