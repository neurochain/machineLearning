---
title: "R Notebook"
output: html_notebook
Recommendation engine
---


```{r}
library(xlsx)

data <- read.xlsx("", sheetIndex = 1)

names(data) <- c("")
head(data)
```



# calculer la matrice de similarité

```{r}
library(dplyr)

data.simil <- select(data, -starts_with("produit"))

head(data.simil)
```


```{r}
library(proxy)
library(ade4)
library(cluster)


simil.matrix <-simil(data.simil, diag = TRUE) 
gower.dist <- daisy(data.simil, metric = "gower")



```


# 

```{r}
summary(gower.dist)

gower.dist <- as.matrix(gower.dist)

print(gower.dist)

```


```{r}

profils <- c("")
    i = 0
for (profil in profils) {
    vecteur_dist <- gower.dist[29 + i, 1:28]
    i = i + 1
    cat("")
    produit_simil_idx = which.min(vecteur_dist)
    simil_val = 1 - min(vecteur_dist)
    simil_produit  = data$produit[produit_simil_idx]
    cat("\n  ", profil, " ", 100*simil_val, " % est :")
    print(simil_produit)
}
```



```{r}

acm <- dudi.acm(data.simil, scannf = FALSE, nf = 5)

md <- dist.dudi(acm)

summary(md)

md <- as.matrix(md)

print(md)


