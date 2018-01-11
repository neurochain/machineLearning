---
title: "Data_cleaning, Anomaly_detection and Coherence"
From: "NeuroChain Lab"
date: "May 15, 2017"
Application: "Transactional Ledger" 
---
  
  # The following algorithmic methods represent the Proof of Concept concerning the integrity calculation and the 
  # anomaly detection in a distributed ledger. It represents tests for NeuroChain project. 
  
  
  ```{r}

library(data.table)
library(proxy)
library(funModeling)
library(ggplot2)


```

Input ledger 

```{r}


LIP_TRD_1_ALISE_R1_20160131.NCC <- read.delim("~/LIP_TRD_1_ALISE_R1_20160131.NCC.txt", header=TRUE, na.strings = c("NA", ""), stringsAsFactors = TRUE)

names_var_TRD <- fread("~/header BCI.CSV", header = FALSE, na.strings = c("NA", ""), sep = "auto")

colnames(LIP_TRD_1_ALISE_R1_20160131.NCC) <- as.character(names_var_TRD[1,1:ncol(LIP_TRD_1_ALISE_R1_20160131.NCC)])

```




```{r}

# Data exploration

library(dplyr)

var_names <- colnames(dataFrame)


var.selection.NA <- function(dataFrame) {   
  N <- nrow(dataFrame)  
  dataFrame <- as.data.frame(dataFrame)
  dataFrame_Status <- df_status(dataFrame)
  vars_to_rm = subset(dataFrame_Status, (dataFrame_Status$p_na > 10) | (dataFrame_Status$unique <= 1) | (((dataFrame_Status$type == 'integer' )| (dataFrame_Status$type == 'integer64')| (dataFrame_Status$type == 'numeric')) &  (dataFrame_Status$unique > 1000)) |  ((dataFrame_Status$type == 'factor') & (dataFrame_Status$unique > 0.02*N))) 
  
  dataFrame <- dataFrame[, !names(dataFrame) %in% vars_to_rm[,"variable"] ]
  
  { return(dataFrame)}  
  
} 

var_selection <- var.selection.NA(LIP_TRD_1_ALISE_R1_20160131.NCC)



```


# Type management


```{r}

var.change.type <- function(dataFrameTOchangeType) {
  
  N <- nrow(dataFrameTOchangeType)
  
  dataFrameStatus <- df_status(dataFrameTOchangeType)
  
  vars_to_change_type = subset(dataFrameStatus, ((dataFrameStatus$type == 'integer') & (dataFrameStatus$unique <= 0.02*N)) | ((dataFrameStatus$type == 'numeric') &    (dataFrameStatus$unique <= 0.02*N)))
  
  
  vars_to_change_type_names <- vars_to_change_type[,"variable"] 
  
  
  dataFrameTOchangeType[,  vars_to_change_type_names] <- lapply(  vars_to_change_type_names, function(x) as.factor(as.character(dataFrameTOchangeType[,x])))
  
  { return(dataFrameTOchangeType)}
  
  
}

var_type_changed <- var.change.type(var_selection)


```

# Imputation


```{r}

Imputation <- function(dataFrameToImpute) { 
  
  library(mice)
  library(imputeR)
  df_status_dataframe <- df_status(dataFrameToImpute)
  
  vars_to_Impute = subset(df_status_dataframe, (df_status_dataframe$q_na > 1) ) 
  
  vars_to_Impute_names <-  vars_to_Impute[,"variable"] 
  
  dataFrame_imput <- dataFrameToImpute[, (names(dataFrameToImpute) %in% vars_to_Impute_names) ]
  
  dataFrame_imput_status <- df_status(dataFrame_imput) 
  var_type <- dataFrame_imput_status$type
  method_imp <- vector()
  
  for (i in 1:ncol(dataFrame_imput)) {
    dataFrame_imput[,i] <- major(dataFrame_imput[,i])  
  }
  
  dataFrameToImpute[, vars_to_Impute_names] <- dataFrame_imput
  
  {return(dataFrameToImpute)}
  
}


Imputed_data_frame <- Imputation(var_type_changed) 

# Data Frame representation

df_status(Imputed_data_frame)


```


# Smart Visualisation


```{r}
var_visualization <- function(dataframe, var_to_viz_name) {
  
}



```

```{r}
colnames(LIP_TRD_1_ALISE_R1_20160131.NCC) <- names_var[1:ncol(LIP_TRD_1_ALISE_R1_20160131.NCC)]


```




```{r}

mu_ratevalue = mean(df_CFL$ratevalue)

rateval <- df_CFL[, "ratevalue"]

rateval <- as.data.frame(rateval)

rateval <- rateval %>% drop_na()
rateval <- as.data.frame(rateval)

dim(rateval[rateval$rateval <10,])
ggplot(rateval,aes(x = rateval)) + 
geom_histogram(alpha=0.75,color="blue", bins = 50)  + theme_minimal()  + labs(title=" ratevalue Distribution", y = "Count per ratevalue") +  geom_vline(aes(xintercept=mu_ratevalue), 
                                                                                                                                            color="blue", linetype="dashed", size=1)    

```


# Determination of the outliers (with fixed threshold)


```{r}
out_val <- as.data.frame(rateval[rateval$rateval > 100,])

rateval <- rateval %>% arrange(desc(rateval))

out_val <- rateval[1:256,]

write.csv(out_val, "ravalue_outlier.csv" )
```


# tracking

```{r}
library(tidyr)
library(dplyr)
library(Hmisc)
library(plyr)

clust_CFL <- df_CFL %>% select(cashflowdiscountedamount, cashflowundiscountedamount)

clust_CFL$bucket <- with(clust_CFL, impute(bucket, 'random'))

clust_CFL$bucket <- as.factor(as.character(clust_CFL$bucket))

clust_CFL$ratenature <-with(clust_CFL, impute(ratenature, 'random'))

clust_CFL$ratenature <- as.numeric(clust_CFL$ratenature)

clust_CFL$legtype <-with(clust_CFL, impute(legtype, 'random'))

clust_CFL$legtype <- as.numeric(clust_CFL$legtype)


```{r}

# Alternative

library(missForest)

dat.missForest<-missForest(clust_CFL,maxiter=10,
                           ntree = 200, variablewise = TRUE)$ximp

```{r}
data_fit_CFL <- clust_CFL[sample(1:nrow(clust_CFL), 1000000),]
data_fit_CFL <- data_fit_CFL %>% drop_na()

```

# Bayesian Network ==> Anomaly detection 

```{r}

library(bnlearn)

bn.hc <- hc(data_fit_CFL)

```


```{r}

plot(bn.hc, main = "Hill-Climbing", highlight = c("cashflowtype"))

```

# Calibration of the model 


```{r}

fittedbn <- bn.fit(bn.hc, data = data_fit_CFL)

```


# Maximum Likelihood calculation 

```{r}

loglikhood <- logLik(fittedbn, clust_CFL, by.sample = TRUE)

plot(loglikhood)

```


```{r}
summary(loglikhood)

summary(loglikhood)
Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA s 
-Inf  -34.60  -31.80    -Inf  -31.26  -26.73      52 


#sorting 
loglikhood_sort <-  sort(loglikhood)


# determination of the threshold 

```{r}

first_outliers <- clust_CFL[ loglikhood %in% loglikhood_sort[1:1000],]
first_20_outliers <- clust_CFL[ loglikhood %in% loglikhood_sort[1:20],]
write.csv(first_20_outliers, "first_20_outliers_NCC.csv")
```

```{r}

bn_outliers <- clust_CFL[loglikhood < -845,]

```




```{r}

Anomalies <- dataframe[loglikhood< -845,]

Deal_ID <- Anmolies$cdealid

bn_outliers <- cbind(bn_outliers, Deal_ID) 

bn_outliers <- bn_outliers %>% drop_na()

write.csv(bn_outliers, "CFL_ouliers_bcp4.csv")

```


# Analysis

```{r}
summary(bn_outliers)

```








```{r}

summary_amount <- as.data.frame (as.matrix(summary(bn_outliers$cashflowundiscountedamount)))


clust_anomaly <- df_CFL[df_CFL$cashflowdiscountedamount == nn,]

loglikhood[df_CFL$cashflowdiscountedamount == nn]


min_amount <- min(df_CFL$cashflowdiscountedamount)

max_amount <- max(df_CFL$cashflowdiscountedamount)

loglikhood_threshold <- max(loglikhood[df_CFL$cashflowdiscountedamount == min_amount],loglikhood[df_CFL$cashflowdiscountedamount == max_amount] )

```

Min.    1st Qu.     Median       Mean    3rd Qu.       Max.       NA s 
-7.607e+10 -1.034e+08 -2.758e+07  3.974e+08  1.545e+08  6.308e+10         12 




# likelihood distribution analysis 

```{r}
mu_CDA = mean(loglikhood) 

# lognormal distribution 

loglk <- as.data.frame(loglikhood)

ggplot(loglk,aes(x =loglk )) + 
geom_histogram(alpha=0.75,color="blue", bins = 50)  + theme_minimal()  + labs(title=" loglikehood  Distribution", y = "loglikehood value") + scale_y_log10() + geom_vline(aes(xintercept=mu_CDA), 
color="blue", linetype="dashed", size=1)  

```




# Density based Algorithms Method 


```{r}
library(dbscan)

lof <- lof(lof_data[1:1000000,], k=5)

### distribution of outlier factors

summary(lof)
hist(lof, breaks=20)

```


```{r}
# pick top k outliers

outliers.score <- lof

outliers <- sort(outliers.score, decreasing = TRUE)[1:700]

print(outliers)

print(lof_data[outliers,]) 










