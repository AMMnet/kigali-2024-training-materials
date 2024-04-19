# This function contains the ode system for the SEIR dynamics
SEIR <- function(t, x, params) {
  with(as.list(c(x, params)), {
    beta = params[1]
    N = params[2]
    gamma = params[3]
    
    S <- x[1]
    I <- x[2]
    R <- x[3]
    
    dS_dt <-  - beta* I * S / N;
    dI_dt <-  beta * I * S / N- gamma * I;
    dR_dt <-  gamma * I ;
    dCumInci_dt <- beta * I * S / N- gamma* I;
    
    X1a <- c(as.vector(dS_dt),  as.vector(dI_dt), as.vector(dR_dt) ) 
    
    return(list(X1a))
  })
}

