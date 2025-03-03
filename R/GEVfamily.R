#' GEV family distribution for fitting a GAMLSS
#'
#' The functions `GEVfisher()` and `GEVquasi()` each define the generalized
#' extreme value (GEV) family distribution, a three parameter distribution, for
#' a [`gamlss.dist::gamlss.family()`][`gamlss.dist::gamlss.family`] object to
#' be used in GAMLSS fitting using the function
#' [`gamlss::gamlss()`][`gamlss::gamlss`]. The only difference
#' between `GEVfisher()` and `GEVquasi()` is the form of scoring method used to
#' define the weights used in the fitting algorithm. Fisher's scoring,
#' based on the expected Fisher information is used in `GEVfisher()`, whereas
#' a quasi-Newton scoring, based on the cross products of the first derivatives
#' of the log-likelihood, is used in `GEVquasi()`. The functions
#' `dGEV`, `pGEV`, `qGEV` and `rGEV` define the density, distribution function,
#' quantile function and random generation for the specific parameterization of
#' the generalized extreme value distribution given in **Details** below.
#'
#' @param mu.link Defines the `mu.link`, with `"identity"` link as the default
#' for the `mu` parameter.
#' @param sigma.link Defines the `sigma.link`, with `"log"` link as the default
#' for the `sigma` parameter.
#' @param nu.link Defines the `nu.link`, with `"identity"` link as the default
#' for the `nu` parameter.
#' @param x,q Vector of quantiles.
#' @param mu,sigma,nu Vectors of location, scale and shape parameter values.
#' @param log,log.p Logical. If `TRUE`, probabilities `eqn{p}` are given as
#'   \eqn{\log(p)}.
#' @param lower.tail Logical. If `TRUE` (the default), probabilities are
#'   \eqn{P[X \leq x]}, otherwise, \eqn{P[X > x]}.
#' @param p Vector of probabilities.
#' @param n Number of observations. If `length(n) > 1`, the length is taken to
#'   be the number required.
#'
#' @details The distribution function of a GEV distribution with parameters
#'  \code{location} = \eqn{\mu}, \code{scale} = \eqn{\sigma (> 0)} and
#'  \code{shape} = \eqn{\xi} (\eqn{= \nu}) is
#'   \deqn{F(x \mid \mu, \sigma, \xi) = P(X \leq x) =
#'   \exp\left\{ -\left[ 1+\xi\left(\frac{x-\mu}{\sigma}\right) \right]_+^{-1/\xi} \right\},}
#'   where \eqn{x_+ = \max(x, 0)}. If \eqn{\xi = 0} the
#'  distribution function is defined as the limit as \eqn{\xi} tends to zero.
#'  The support of the distribution depends on \eqn{\xi}: it is
#'  \eqn{x \leq \mu - \sigma / \xi}{x <= \mu - \sigma / \xi} for \eqn{\xi < 0};
#'  \eqn{x \geq \mu - \sigma / \xi}{x >= \mu - \sigma / \xi} for \eqn{\xi > 0};
#'  and \eqn{x} is unbounded for \eqn{\xi = 0}.
#'  See
#'  \url{https://en.wikipedia.org/wiki/Generalized_extreme_value_distribution}
#'  and/or Chapter 3 of Coles (2001) for further information.
#'
#' For each observation in the data, the restriction that \eqn{\xi > -1/2} is
#' imposed, which is necessary for the usual asymptotic likelihood theory to be
#' applicable.
#'
#' @return `GEVfisher()` and `GEVquasi()` each return a
#'   [`gamlss.dist::gamlss.family()`][`gamlss.dist::gamlss.family`] object
#'   which can be used to fit a regression model with a GEV response
#'   distribution using the
#'   [`gamlss::gamlss()`][`gamlss::gamlss`] function. `dGEV()` gives the density,
#'   `pGEV()` gives the distribution function, `qGEV()` gives the quantile
#'   function, and `rGEV()` generates random deviates.
#' @seealso [`fitGEV`],
#'   [`gamlss.dist::gamlss.family()`][`gamlss.dist::gamlss.family`],
#'   [`gamlss::gamlss()`][`gamlss::gamlss`]
#' @references Coles, S. G. (2001) *An Introduction to Statistical
#'   Modeling of Extreme Values*, Springer-Verlag, London.
#'   Chapter 3: \doi{10.1007/978-1-4471-3675-0_3}
#' @section Examples:
#' See the examples in [`fitGEV()`].
#' @name GEV
NULL
## NULL

#' @rdname GEV
#' @export
GEVfisher <- function(mu.link = "identity", sigma.link = "log",
                      nu.link = "identity") {

  mstats <- gamlss.dist::checklink("mu.link", "GEV", substitute(mu.link),
                                   c("1/mu^2", "log", "identity"))
  dstats <- gamlss.dist::checklink("sigma.link", "GEV", substitute(sigma.link),
                                   c("inverse", "log", "identity"))
  vstats <- gamlss.dist::checklink("nu.link", "GEV",substitute(nu.link),
                                   c("inverse", "log", "identity"))

  structure(
    list(family = c("GEV", "Generalized Extreme Value"),
         parameters = list(mu = TRUE, sigma = TRUE, nu = TRUE),
              nopar = 3,
               type = "Continuous",
            mu.link = as.character(substitute(mu.link)),
         sigma.link = as.character(substitute(sigma.link)),
            nu.link = as.character(substitute(nu.link)),
         mu.linkfun = mstats$linkfun,
      sigma.linkfun = dstats$linkfun,
         nu.linkfun = vstats$linkfun,
         mu.linkinv = mstats$linkinv,
      sigma.linkinv = dstats$linkinv,
         nu.linkinv = vstats$linkinv,
              mu.dr = mstats$mu.eta,
           sigma.dr = dstats$mu.eta,
              nu.dr = vstats$mu.eta,
               dldm = function(y, mu, sigma, nu) {
                 dl <- nieve::dGEV(x = y, loc = mu, scale = sigma, shape = nu,
                                   log = TRUE, deriv = TRUE)
                 dldm <- attr(dl, "gradient")[, "loc"]
                 return(dldm)
               },
             d2ldm2 = function(y, mu, sigma, nu) {
               dldm2 <- -gev11e(scale = sigma, shape = nu)
               return(dldm2)
             },
               dldd = function(y, mu, sigma, nu) {
                 dl <- nieve::dGEV(x = y, loc = mu, scale = sigma, shape = nu,
                                   log = TRUE, deriv = TRUE)
                 dldd <- attr(dl, "gradient")[, "scale"]
                 return(dldd)
               },
             d2ldd2 = function(y, mu, sigma, nu) {
               dldd2 <- -gev22e(scale = sigma, shape = nu)
               return(dldd2)
             },
               dldv = function(y, mu, sigma, nu) {
                 dl <- nieve::dGEV(x = y, loc = mu, scale = sigma, shape = nu,
                                   log = TRUE, deriv = TRUE)
                dldv <- attr(dl, "gradient")[, "shape"]
                return(dldv)
             },
             d2ldv2 = function(y, mu, sigma, nu) {
               dldv2 <- -gev33e(shape = nu)
               return(dldv2)
             },
            d2ldmdd = function(y, mu, sigma, nu) {
              dldmdd <- -gev12e(scale = sigma, shape = nu)
              return(dldmdd)
            },
            d2ldmdv = function(y, mu, sigma, nu) {
              dldmdv <- -gev13e(scale = sigma, shape = nu)
              return(dldmdv)
            },
            d2ldddv = function(y, mu, sigma, nu) {
              dldddv <- -gev23e(scale = sigma, shape = nu)
              return(dldddv)
            },
         G.dev.incr = function(y, mu, sigma, nu,...) {
          val <- -2 * dGEV(x = y, mu = mu, sigma = sigma, nu = nu, log = TRUE)
          return(val)
        },
              rqres = expression(rqres(pfun = "pGEV", type = "Continuous",
                                       y = y, mu = mu, sigma = sigma, nu = nu)),
# sqrt(6) / pi is approximately 0.78
# 0.57722 * sqrt(6) / pi is approximately 0.45
# The gamlss.dist::RGE() code had a typo in mu.initial + 0.45 should be - 0.45
# The next (commented out) line starts from a crude stationary fit
#         mu.initial = expression(mu <- rep(mean(y) - 0.45 * sd(y), length(y))),
         mu.initial = expression(mu <- y - 0.45 * sd(y)),
      sigma.initial = expression(sigma <- rep(0.78 * sd(y), length(y))),
         nu.initial = expression(nu <- rep(0.1, length(y))),
           mu.valid = function(mu) TRUE,
        sigma.valid = function(sigma) all(sigma > 0),
           nu.valid = function(nu) all(nu > -0.5),
            y.valid = function(y) TRUE
    ),
  class = c("gamlss.family","family")
  )
}

#' @rdname GEV
#' @export
GEVquasi <- function(mu.link = "identity", sigma.link = "log",
                     nu.link = "identity") {

  mstats <- gamlss.dist::checklink("mu.link", "GEV", substitute(mu.link),
                                   c("1/mu^2", "log", "identity"))
  dstats <- gamlss.dist::checklink("sigma.link", "GEV", substitute(sigma.link),
                                   c("inverse", "log", "identity"))
  vstats <- gamlss.dist::checklink("nu.link", "GEV",substitute(nu.link),
                                   c("inverse", "log", "identity"))

  structure(
    list(family = c("GEV", "Generalized Extreme Value"),
         parameters = list(mu = TRUE, sigma = TRUE, nu = TRUE),
         nopar = 3,
         type = "Continuous",
         mu.link = as.character(substitute(mu.link)),
         sigma.link = as.character(substitute(sigma.link)),
         nu.link = as.character(substitute(nu.link)),
         mu.linkfun = mstats$linkfun,
         sigma.linkfun = dstats$linkfun,
         nu.linkfun = vstats$linkfun,
         mu.linkinv = mstats$linkinv,
         sigma.linkinv = dstats$linkinv,
         nu.linkinv = vstats$linkinv,
         mu.dr = mstats$mu.eta,
         sigma.dr = dstats$mu.eta,
         nu.dr = vstats$mu.eta,
         dldm = function(y, mu, sigma, nu) {
           dl <- nieve::dGEV(x = y, loc = mu, scale = sigma, shape = nu,
                             log = TRUE, deriv = TRUE)
           dldm <- attr(dl, "gradient")[, "loc"]
           return(dldm)
         },
         d2ldm2 = function(y, mu, sigma, nu) {
           dl <- nieve::dGEV(x = y, loc = mu, scale = sigma, shape = nu,
                             log = TRUE, deriv = TRUE)
           dldm <- attr(dl, "gradient")[, "loc"]
           dldm2 <- -dldm * dldm
           return(dldm2)
         },
         dldd = function(y, mu, sigma, nu) {
           dl <- nieve::dGEV(x = y, loc = mu, scale = sigma, shape = nu,
                             log = TRUE, deriv = TRUE)
           dldd <- attr(dl, "gradient")[, "scale"]
           return(dldd)
         },
         d2ldd2 = function(y, mu, sigma, nu) {
           dl <- nieve::dGEV(x = y, loc = mu, scale = sigma, shape = nu,
                             log = TRUE, deriv = TRUE)
           dldd <- attr(dl, "gradient")[, "scale"]
           dldd2 <- -dldd * dldd
           return(dldd2)
         },
         dldv = function(y, mu, sigma, nu) {
           dl <- nieve::dGEV(x = y, loc = mu, scale = sigma, shape = nu,
                             log = TRUE, deriv = TRUE)
           dldv <- attr(dl, "gradient")[, "shape"]
           return(dldv)
         },
         d2ldv2 = function(y, mu, sigma, nu) {
           dl <- nieve::dGEV(x = y, loc = mu, scale = sigma, shape = nu,
                             log = TRUE, deriv = TRUE)
           dldv <- attr(dl, "gradient")[, "shape"]
           dldv2 <- -dldv * dldv
           return(dldv2)
         },
         d2ldmdd = function(y, mu, sigma, nu) {
           dl <- nieve::dGEV(x = y, loc = mu, scale = sigma, shape = nu,
                             log = TRUE, deriv = TRUE)
           dldm <- attr(dl, "gradient")[, "loc"]
           dldd <- attr(dl, "gradient")[, "scale"]
           dldmdd <- -dldm * dldd
           return(dldmdd)
         },
         d2ldmdv = function(y, mu, sigma, nu) {
           dl <- nieve::dGEV(x = y, loc = mu, scale = sigma, shape = nu,
                             log = TRUE, deriv = TRUE)
           dldm <- attr(dl, "gradient")[, "loc"]
           dldv <- attr(dl, "gradient")[, "shape"]
           dldmdv <- -dldm * dldv
           return(dldmdv)
         },
         d2ldddv = function(y, mu, sigma, nu) {
           dl <- nieve::dGEV(x = y, loc = mu, scale = sigma, shape = nu,
                             log = TRUE, deriv = TRUE)
           dldd <- attr(dl, "gradient")[, "scale"]
           dldv <- attr(dl, "gradient")[, "shape"]
           dldddv <- -dldd * dldv
           return(dldddv)
         },
          G.dev.incr = function(y, mu, sigma, nu,...) {
           val <- -2 * dGEV(x = y, mu = mu, sigma = sigma, nu = nu, log = TRUE)
           return(val)
         },
         rqres = expression(rqres(pfun = "pGEV", type = "Continuous",
                                  y = y, mu = mu, sigma = sigma, nu = nu)),
         mu.initial = expression(mu <- y + 0.45 * sd(y)),
         sigma.initial = expression(sigma <- rep(0.78 * sd(y), length(y))),
         nu.initial = expression(nu <- rep(0.1, length(y))),
         mu.valid = function(mu) TRUE,
         sigma.valid = function(sigma) all(sigma > 0),
         nu.valid = function(nu) all(nu > -0.5),
         y.valid = function(y) TRUE
    ),
    class = c("gamlss.family","family")
  )
}

#' @rdname GEV
#' @export
dGEV <- function(x, mu = 0, sigma = 1, nu = 0, log = FALSE) {
  return(nieve::dGEV(x = x, loc = mu, scale = sigma, shape = nu,
                     log = log))
}

#' @rdname GEV
#' @export
pGEV <- function(q, mu = 0, sigma = 1, nu = 0, lower.tail = TRUE,
                 log.p = FALSE) {
  return(nieve::pGEV(q = q, loc = mu, scale = sigma, shape = nu))
}

#' @rdname GEV
#' @export
qGEV <- function(p, mu = 0, sigma = 1, nu = 0, lower.tail = TRUE,
                 log.p = FALSE) {
  return(nieve::qGEV(p = p, loc = mu, scale = sigma, shape = nu))
}

#' @rdname GEV
#' @export
rGEV <- function(n, mu = 0, sigma = 1, nu = 0) {
  return(nieve::rGEV(n = n, loc = mu, scale = sigma, shape = nu))
}
