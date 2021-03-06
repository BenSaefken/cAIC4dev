#' @method print cAIC
#' @rdname summary.cAIC
#' @export
print.cAIC <- function(x, ...)
{
  
  prdf <- data.frame(
    a = c("Conditional log-likelihood: ",
          "Degrees of freedom: ",
          "Conditional Akaike information: "),
    b = unlist(x[c("loglikelihood", "df", "caic")]))
  colnames(prdf) <- c()
  
  if(x$new){
    cat("The original model was refitted due to zero variance components.\n")
    cat("Refitted model: ", Reduce(paste, deparse(formula(c$reducedModel))), "\n")
  }
    
  print(prdf, row.names = FALSE)
  invisible(prdf)
  
}


#' Comparison of several lmer objects via cAIC
#' 
#' Takes one or more \code{lmer}-objects and produces a table 
#' to the console.
#' 
#' @param object a fitted \code{cAIC}-object
#' @param ... additional objects of the same type
#' 
#' @seealso \code{\link{cAIC}} for the model fit.
#' 
#' @return a table comparing the cAIC relevant information of all models
#' 
#' @aliases print.cAIC
#' 
#' @export
anocAIC <- function(object, ...) {
  
  # get list of models
  objs <- c(object, list(...))
  
  # check correct input
  if(any(sapply(objs, function(x) !inherits(x, "merMod"))))
    stop("anocAIC can only deal with objects of class lmerMod or glmerMod")
  
  # calculate cAICs
  cAICs <- lapply(objs, cAIC)
  
  # extract formulas
  frms <- sapply(objs, function(x) Reduce(paste, deparse(formula(x))))
  # replace formulas, where the model was refitted
  refit <- sapply(cAICs, "[[", "new")
  if(any(refit))
    frms[which(refit)] <- sapply(cAICs[which(refit)], function(x) 
      Reduce(paste, deparse(formula(x$reducedModel))))
  
  # create returning data.frame
  ret <- as.data.frame(do.call("rbind", lapply(cAICs, function(x)  
    unlist(x[c("loglikelihood", "df", "caic", "new")]))))
  ret[,4] <- as.logical(ret[,4])
  rownames(ret) <- make.unique(frms, sep = " % duplicate #")
  colnames(ret) <- c("Cond. log-likelihood",
                     "df",
                     "cAIC",
                     "Refit")
  
  # print and return
  print(ret)
  invisible(ret)
}
