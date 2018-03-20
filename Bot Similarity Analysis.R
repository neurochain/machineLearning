
# Similarity analysis 
  
  
  
library(corrplot)  
library(tm)
library(stringi)
library(proxy)
library(funModeling)
library(cluster)
library(fpc)



  # the folders 
  rep_courant <<- "C:/Users/Desktop/folder1"
  rep_courant1 <<- "C:/Users/Desktop/folder2"



  ## the corpus 
  text_corpus <- Corpus(DirSource(rep_courant),readerControl=list (reader,language = "fr"))
  #text_corpus <- Corpus(VectorSource(cv_text))
  inspect(text_corpus)
  
  ## cleaning 
  
  
  (kill_chars <- content_transformer (function(x, pattern) gsub(pattern, "dieze", x)))
  text_corpus <- tm_map (text_corpus, kill_chars, "#")
  
  text_corpus <- tm_map(text_corpus, content_transformer(tolower))
  text_corpus <- tm_map(text_corpus, removePunctuation,preserve_intra_word_dashes = TRUE)
  text_corpus <- tm_map(text_corpus, removeNumbers)
  
  text_corpus <- tm_map(text_corpus, stripWhitespace)
  
  text_corpus <- tm_map(text_corpus, function(x)removeWords(x,stopwords(kind = "fr")))
  #text_corpus <- tm_map(text_corpus, function(x)removeWords(x,c("quils", "cestadire", "tout")))  
  
  library(SnowballC)
  xxx = stemDocument(text_corpus, language = meta(text_corpus, "language"))
  
  
  
  ################################
  ####### The similarities  
  
  # First approach 
  
  
  
  # With frequencies :
  docsTDM <- removeSparseTerms(
    DocumentTermMatrix(text_corpus, control=list(weighting=weightTfIdf)),
    0.7) 
  findAssocs(docsTDM, c("adresse","ville","localisation"), c(1,1,1))
  findFreqTerms(docsTDM, lowfreq = 2, highfreq = 10)
  
  
  docsTDM <- as.matrix(docsTDM)
  typeof(docsTDM)
  
  dim(docsTDM)
  names(docsTDM)
  inspect(docsTDM)
  
  
  
  # Plot 
  corrplot (docsTDM, is.corr=FALSE)
  
  # compute a distance matrix and then apply hclust 
  dist4 <- dist(docsTDM, method="cosine")
  dim(dist4)
  my_data_status=df_status(dist4)
  plot(dist4)
  corrplot (dist4, is.corr=FALSE)
  
  hc4 <- hclust(dist4, method="ward.D2")
  plot(hc4)
  
  ## clusterisation kmeans 
  kmeans4 <- kmeans (docsTDM, centers=3)
  # afficher les cluster (c.f. ci-dessous)
  kmeans4$cluster
  wwww <- setDT(kmeans4$centers)
  
  groupe1 <- which(kmeans4$cluster==1)
  groupe2 <- which(kmeans4$cluster==2)
  groupe3 <- which(kmeans4$cluster==3)
  
  
  # plot the clusters 
  plotcluster (docsTDM, kmeans4$cluster)
  
  table (kmeans4$cluster)
  
  clusplot(docsTDM, kmeans4$cluster, color=TRUE, shade=TRUE, 
           labels=2, lines=0)
  

  library (kernlab)
  pca2 <- kpca (as.matrix(docsTDM), features=2)
  plot( rotated(pca2), pty="s",
        xlab="1st Principal Component", ylab="2nd Principal Component" )
  
  
  
  
  
  
  ## The second approach 
  ## Applied to movies 
  
  ##############
  ##############
  
  
  library(text2vec)
  library(data.table)
  
  
  data("movie_review")
  setDT(movie_review)  
  setkey(movie_review, id) 
  set.seed(2016L)
  all_ids = movie_review$id
  
  train_ids = sample(all_ids, 4000)
  test_ids = setdiff(all_ids, train_ids)
  train = movie_review[J(train_ids)]
  test = movie_review[J(test_ids)]
  
  
  
  
  # define preprocessing function and tokenization fucntion
  prep_fun = tolower
  tok_fun = word_tokenizer
  
  it_train = itoken(train$review, 
                    preprocessor = prep_fun, 
                    tokenizer = tok_fun, 
                    ids = train$id, 
                    progressbar = FALSE)
  vocab = create_vocabulary(it_train)
  
  vectorizer = vocab_vectorizer(vocab)
  t1 = Sys.time()
  dtm_train = create_dtm(it_train, vectorizer)
  print(difftime(Sys.time(), t1, units = 'sec'))
  dim(dtm_train)
  identical(rownames(dtm_train), train$id)

  
  library(glmnet)
  NFOLDS = 4 # le nombre de cross validation 
  t1 = Sys.time()
  glmnet_classifier = cv.glmnet(x = dtm_train, y = train[['sentiment']], 
                                family = 'binomial', 
                                # L1 penalty
                                alpha = 1,
                                # interested in the area under ROC curve
                                type.measure = "auc",
                                # 5-fold cross-validation
                                nfolds = NFOLDS,
                                # high value is less accurate, but has faster training
                                thresh = 1e-3,
                                # again lower number of iterations for faster training
                                maxit = 1e3)
  print(difftime(Sys.time(), t1, units = 'sec'))
  
  plot(glmnet_classifier)
  
  
  it_test = test$review %>% 
    prep_fun %>% 
    tok_fun %>% 
    itoken(ids = test$id, 
           
           progressbar = FALSE)
  
  dtm_test = create_dtm(it_test, vectorizer)
  
  preds = predict(glmnet_classifier, dtm_test, type = 'response')[,1]
  glmnet:::auc(test$sentiment, preds)
  
  
  









