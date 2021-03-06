
NetworkValidate <- function(HostList, Network, Fun = colSums, Silent = F){

  require(Matrix)

  pHosts <- HostList
  pHosts2 <- intersect(pHosts, rownames(Network))
  if (length(pHosts2) > 1) {
    FocalNet <- Network[pHosts2, ]
    ValidEst <- list()
    for(b in pHosts2) {
      # print(b)
      pHosts4 <- setdiff(pHosts2, b)
      pHosts3 <- setdiff(colnames(FocalNet), pHosts4)
      Estimates <- FocalNet[pHosts4, pHosts3] # %>% as.matrix

      if(is.null(dim(Estimates))){
        Estimates <- t(data.frame(Estimates))
      }

      ValidFunction <- Fun

      Ests <- data.frame(Sp = names(sort(ValidFunction(Estimates),
                                         decreasing = T)), Count = sort(ValidFunction(Estimates),
                                                                        decreasing = T)/nrow(Estimates)) %>% mutate(Focal = ifelse(Sp ==
                                                                                                                                     b, "Observed", "Predicted"), Iteration = b)
      ValidEst[[b]] <- Ests
    }
    ValidEst <- ValidEst %>% bind_rows %>% group_by(Sp) %>%
      dplyr::summarise(Count = mean(Count)) %>% slice(order(Count,
                                                            decreasing = T)) %>% mutate(Focal = ifelse(Sp %in%
                                                                                                         pHosts2, "Observed", "Predicted"))
    ValidEst$Rank <- nrow(ValidEst) - rank(ValidEst$Count,
                                           ties.method = "average") + 1
  }
  else {
    ValidEst <- NA
    if(!Silent) print("Hosts Not Found!")
  }

  return(ValidEst)

}
