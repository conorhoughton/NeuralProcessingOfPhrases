/*
  Model that performs logistic(sum(alpha[i])) rather than prod(logistic(alpha[i]))
*/

// User defined probability functions (up to constant)
functions{
    real wrapped_cauchy_lpdf(real y, real mu, real gamma){
      return log(sinh(gamma)) - log(cosh(gamma) - cos(y-mu));
    }
    real bundt_lpdf(vector y){
      real norm = sqrt(dot_self(y));
      return log(norm) - norm;
    }
}
data{
  int N; // Number of data points
  int E; // Number of electrodes
  int C; // Number of conditions
  int P; // Number of participants

  int<lower=1, upper=E> electrode_idx[N]; // What electrode was y[i] recorded from
  int<lower=1, upper=C> condition_idx[N]; // What condition present during recording of y[i]
  int<lower=1, upper=P> participant_idx[N];

  vector[N] y; // Angles
}
parameters{
  vector[2] mu_raw[P,E];
  vector[E] alpha_E;
  vector[C] alpha_C;
  vector[P] alpha_P;
  real  s;
  real alpha;
}
model{

  // sample for mu
  for(i in 1:P){
    for(j in 1:E){
      mu_raw[i,j] ~ bundt();
    }
  }

  s       ~ exponential(5.0);
  alpha   ~ normal(0, s);
  alpha_E ~ normal(0, s);
  alpha_C ~ normal(0, s);
  alpha_P ~ normal(0, s);

  for(i in 1:N){
    y[i] ~ wrapped_cauchy(atan2(mu_raw[participant_idx[i], electrode_idx[i], 1], mu_raw[participant_idx[i], electrode_idx[i], 2]),
                          -log(inv_logit(alpha + alpha_E[electrode_idx[i]] + alpha_C[condition_idx[i]] + alpha_P[participant_idx[i]])));
  }
}
