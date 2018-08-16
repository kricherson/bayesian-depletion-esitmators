data {
   // Number of observations
   int<lower=0> Nobs;
   // Number of vessels
   int<lower=0> Nv;
   // Number of years
   int<lower=0> Ny;
   //Day in season
   vector[Nobs] dayinseason;
 
   // Year and vessel indexes
   int<lower=1> vessel[Nobs];
   int<lower=1> year[Nobs];
   int<lower=1> year_for_vessel[Nv]; //matches year to vessel
 
   // Dependent variable: cpue
   real cpue[Nobs];
   // Predictor: cumulative catch
   real ccatch[Nobs];
 }
 
parameters {
   // Mean X-intercept/N0 
   real<lower=0> N_0;

   // Mean slope
   real<lower=0> q;
 
   // Observation level error (base)
   real<lower=0> sigma_e0;
 
   // Vessel level random effect
   real u_0vy[Nv]; //deviation from annual mean intercept
   real<lower=0> sigma_u0vy;
 
   // Year random effect
   real<lower=0> sigma_N0; //SD of N0 across years
   real<lower=0> sigma_q; //SD of q across years

   // Yearly ntercepts and slopes
   real<lower=0> N_0y[Ny]; 
   real<lower=0> qy[Ny];

   //Exponent of variance structure
   real b;

 }
 
 transformed parameters  {
 	// vessel level Y intercepts
 	real beta_0vy[Nv];
   
   // Individual mean
   real mu[Nobs];

   // Varying error term
   real sigmab[Nobs];
   
   // Vessel level random Y intercepts (in terms of X intercept and slope)
   for (v in 1:Nv) {
     beta_0vy[v] = N_0y[year_for_vessel[v]]*qy[year_for_vessel[v]] + u_0vy[v];
   }
   // Individual mean
   for (i in 1:Nobs) {
     mu[i] = beta_0vy[vessel[i]] - qy[year[i]] * ccatch[i];
     sigmab[i] =  (dayinseason[i]^b)*sigma_e0; 
   }

 }
 
model {
   // Priors
   // Flat priors for now
 
   // Random effects distribution. Assume N0 and q are lognormally-distributed, vessel RE is normally distributed
   N_0y  ~ lognormal(N_0, sigma_N0);
   qy  ~ lognormal(q, sigma_q);
   u_0vy ~ normal(0, sigma_u0vy);
 
   // Likelihood
   cpue ~ normal(mu, sigmab);
 }
