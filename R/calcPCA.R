#' Principal Component Analysis.
#'
#' \code{calcPCA} calculates PCA-matrix for the given ExpressionSet
#'     and returns this matrix encoded to JSON.
#'
#' @param es an ExpressionSet object, should be normalized
#'
#' @param replacena method for replacing NA values (mean by default)
#'
#' @return json with full description of the plot for plotly.js
#'
#' @import ggplot2
#' @import htmltools
#' @import jsonlite
#'
#' @examples
#' \dontrun{
#' data(es)
#' calcPCA(es)
#' }
#' @keywords internal
calcPCA <- function(es, replacena = "mean") {

    scaledExprs <- unname(exprs(es))

    naInd <- which(is.na(scaledExprs), arr.ind = TRUE)
    if (nrow(naInd) > 0) {
        replaceValues <- apply(scaledExprs, 1, replacena, na.rm=TRUE)
        scaledExprs[naInd] <- replaceValues[naInd[,1]]
    }

    scaledExprs <- t(scale(t(scaledExprs)))
    rowsToPca <- which(!apply(is.na(scaledExprs), 1, any))

    pca <- stats::prcomp(t(scaledExprs[rowsToPca, ]))
    explained <- (pca$sdev) ^ 2 / sum(pca$sdev ^ 2)

    xs <- sprintf("PC%s", seq_along(explained))
    xlabs <- sprintf("%s (%.1f%%)", xs, explained * 100)

    pca.res <- as.matrix(pca$x)
    colnames(pca.res) <- NULL
    row.names(pca.res) <- NULL
    return(jsonlite::toJSON(list(pca = t(pca.res), xlabs = xlabs)))
}

