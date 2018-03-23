# Restricted Boltzmann Machine
# Composed by a hidden layer of 4 neurones based on sigmoïd function 

library(ramify)


# Fonction sigmoïd
sigmoid<-function(x){
  output=1/(1+exp(-x))
  return(output)
}

# the derivative 
sigmoid_output_to_derivative<-function(output){
  return(output*(1-output))
}

set.seed(1)
# Les données
MyData <- read.csv(file="", header=TRUE, sep=",")

X= replicate(hidden_dim, rnorm(5))
Y= replicate(1,rnorm(1))
head(MyData)
X=as.matrix(MyData[,4:8])/10
head(X)
Y=as.matrix(MyData[,3])
head(Y)

# Variables 
alpha=0.1
input_dim=5
hidden_dim=4
output_dim=1

# weight vectors  W1 et W2
#W1=matrix(0.5,input_dim,hidden_dim)
#W2=matrix(0.5,hidden_dim,output_dim)
W1=abs(replicate(hidden_dim, rnorm(input_dim)))
W2=abs(replicate(output_dim, rnorm(hidden_dim)))
#Initialisation des vecteurs poids nous permettant d'actualiser les poids W1 et W2
W1_update=matrix(0,input_dim,hidden_dim)
W2_update=matrix(0,hidden_dim,output_dim)
#layer_2_error=1

for(i in 1:100){
  
  # output neurone
  A=sigmoid(XS[i,]%*%W1)
  
  # output value
  sortie=A%*%W2
  
  # Errors 
  layer_2_error=YS[i,]-sortie
  layer_2_delta=layer_2_error
  print(layer_2_delta)
  
  
  layer_1_delta= layer_2_delta%*%t(W2)*sigmoid_output_to_derivative(A)+rnorm(1,0,1)/10
  
  # weight actualisation 
  W1_update=W1_update+X[i,]%*%layer_1_delta
  W2_update=W2_update+ t(A)%*%layer_2_delta
  
  W1=W1+W1_update*alpha
  W2=W2+W2_update*alpha
  W1_update=W1_update*0
  W2_update=W2_update*0
  
}

sortieT=matrix(0,100,1)
for(i in 600:700){

AT=sigmoid(XS[i,]%*%W1)


sortieT[i-600]=AT%*%W2
}
YS[600:700,]

X=as.matrix(MyData[,4:8])
XS=scale(X)
summary(XS)
#X[,1]=X[,1]/max(X[,1])
#X[,2]=X[,2]/max(X[,2])
#X[,3]=X[,3]/max(X[,3])
#X[,4]=X[,4]/max(X[,4])

max(XS[,1])

head(X)
Y=as.matrix(MyData[,3])
#Y[,1]=Y[,1]/max(Y[,1])
YS=scale(Y)

# Variables 
alpha=0.15
input_dim=5
hidden_dim=6
output_dim=1



W1=abs(replicate(hidden_dim, rnorm(input_dim)))
W2=abs(replicate(output_dim, rnorm(hidden_dim)))
H=abs(replicate(hidden_dim, rnorm(hidden_dim)))

W1_update=matrix(0,input_dim,hidden_dim)
W2_update=matrix(0,hidden_dim,output_dim)
H_update=matrix(0,hidden_dim,hidden_dim)
#layer_2_error=1
A_precedent=matrix(0,1,hidden_dim)
future_A=matrix(0,1,hidden_dim)
for(i in 1:100){
  
  #  sigmoïd activation
  A=sigmoid(XS[i,]%*%W1+A_precedent%*%H)
  
  # output values 
  sortie=A%*%W2
  
  
  layer_2_error=YS[i,]-sortie
  layer_2_delta=layer_2_error
  print(layer_2_delta)
  
  
  layer_1_delta=future_A%*%t(H)+layer_2_delta%*%t(W2)*sigmoid_output_to_derivative(A)
  
  
  W1_update=W1_update+X[i,]%*%layer_1_delta
  W2_update=W2_update+ t(A)%*%layer_2_delta
  H_update=t(A_precedent)%*%layer_1_delta
  
  W1=W1+W1_update*alpha
  W2=W2+W2_update*alpha
  H=H+H_update*alpha
  
  A_precedent=A
  future_A=layer_1_delta
  
  W1_update=W1_update*0
  W2_update=W2_update*0
  H_update=H_update*0
}

