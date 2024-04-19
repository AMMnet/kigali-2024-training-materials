functions {
  real[] sir(real t, real[] y, real[] theta, 
             real[] x_r, int[] x_i) {
      //We declare the state variables and store them in 
      // y as follows
      
      real S = y[1];
      real I = y[2];
      real R = y[3];
      
       // we declare the total population as an integer
   
      real N = x_i[1] ; 
      
       // We declare the estimated parameters and store them in theta
  
      real beta = theta[1];
      real gamma = theta[2];
      
      // Here, the model equations are presented and declared accordingly
      real dS_dt = -beta * I * S / N;
      real dI_dt =  beta * I * S / N - gamma * I;
      real dR_dt =  gamma * I;
      
      return {dS_dt, dI_dt, dR_dt};
  }
}




//Fixed data is declared in the data block: No fixed parameters, 
//all paramters are estimated 

data {
  int<lower=1> n_days; // this is the lenght of cases. Number of days
  real y0[3];
  real t0;
  real ts[n_days]; // lenghth of t
  int N;
  int cases[n_days];
}

//We code transforms of the data in the transformed data block. 
//In this example, we transform our data to match the signature of 
//sir (with x_r being of length 0 because we have nothing to put in it).
transformed data {
  real x_r[0];
  int x_i[1] = { N };
}

//We next declare the model parameters. If you want some parameter
//to be bounded, and it is not already guaranteed by its prior, you 
//need to specify <lower=a, upper=b> when declaring this parameter. 
//Note that this is how you put a 
//truncated prior distribution on a parameter.
parameters {
  real<lower=0> gamma;
  real<lower=0> beta;
  real<lower=0> phi_inv;
}

transformed parameters{
  real y[n_days, 3];
  real phi = 1. / phi_inv;
  {
    // estimated parameters
    real theta[2];
    theta[1] = beta;
    theta[2] = gamma;
//We evaluate the solution numerically by using one of Stan’s 
//numerical integrators. We opt for the Runge-Kutta 4th/5th order
 //order but the user can consider other options. A call to the integrator looks as follows
    y = integrate_ode_rk45(sir, y0, t0, ts, theta, x_r, x_i);
  }
}
model {
  //priors
  beta ~ normal(2, 1);
  gamma ~ normal(0.4, 0.5);
  phi_inv ~ exponential(5);
  
  //sampling distribution
  //col(matrix x, int n) - The n-th column of matrix x. Here the number 
  //of infected people 
  cases ~ neg_binomial_2(col(to_matrix(y), 2), phi);
}
generated quantities {
  real R0 = beta / gamma;
  real recovery_time = 1 / gamma; 
  real pred_cases[n_days];
  pred_cases = neg_binomial_2_rng(col(to_matrix(y), 2), phi);
}






