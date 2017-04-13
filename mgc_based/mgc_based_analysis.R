require('igraph')
require('ggplot2')
require('reshape')
# require('lsr')



setwd("~/git/subgraph/mgc_based/")

listGs<- list.files(path = "../graphml/", pattern = "*.graphml")

#read in covariates and graph list
#find those with common ids, sort by id

covariates<- read.csv("../covariates/predictors.csv",stringsAsFactors = F)
ids <- unlist( lapply(listGs,function(x)strtrim(x,6)))
common_id<- intersect(covariates$RUNNO , ids)

covariates <- covariates[covariates$RUNNO%in%common_id,]
covariates <- covariates[order(covariates$RUNNO),]  

listGs<- listGs[ids%in%common_id]
listGs<- listGs[order(listGs)]

graphList<- lapply(listGs, function(x){
  read.graph( file = paste("../graphml/",x,sep = ""),format = "graphml")
})

AdjacencyList<- lapply(graphList, function(x){
  get.adjacency(x)
})

HemisphereList<- lapply(graphList, function(x){
  get.vertex.attribute(x,name="hemisphere")
})

DegreeList<- lapply(AdjacencyList, function(x){
  rowSums(as.matrix(x))
  })

n = nrow(AdjacencyList[[1]])
########################
## Compute all local corr
library(ecodist)
library(energy)
library(HHG)
source("MGCLocalCorr.R")


source("./MGCSampleStat.R")


LowerTriMatrix = sapply(AdjacencyList,function(x){
  x = as.matrix(x)
  x[lower.tri(x)]
})


AdjMatrix = t(LowerTriMatrix[,covariates$GENOTYPE>=1])
GenoType = covariates$GENOTYPE[covariates$GENOTYPE>=1]

A = as.matrix(dist(AdjMatrix))
B = as.matrix(dist(GenoType))

mgc_result = MGCSampleStat(A,B)
mgc_result


ldcorr=MGCLocalCorr(A,B,option='dcor')$corr;
lmdcorr=MGCLocalCorr(A,B,option='mcor')$corr
lmantel=MGCLocalCorr(A,B,option='mantel')$corr

ldcorr
lmdcorr
lmantel


### Permutation Test of local corr
source("MGCSampleStat.R")
test=MGCSampleStat(A,B)
test

source("MGCPermutationTest.R")
test=MGCPermutationTest(A,B,rep=1000,option='mcor')
test