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
  real<lower=0> s;
  real alpha;
}
transformed parameters{
  real mu_vec[N];
  real gamma_vec[N];

  for(i in 1:N){
    mu_vec[i] = atan2(mu_raw[participant_idx[i], electrode_idx[i], 1], mu_raw[participant_idx[i], electrode_idx[i], 2]);
    gamma_vec[i] = -log(inv_logit(alpha + s*(alpha_E[electrode_idx[i]] + alpha_C[condition_idx[i]] + alpha_P[participant_idx[i]])));
  }

}
model{

  // sample for mu
  for(i in 1:P){
    for(j in 1:E){
      mu_raw[i,j] ~ bundt();
    }
  }

  alpha   ~ std_normal();
  alpha_E ~ std_normal();
  alpha_C ~ std_normal();
  alpha_P ~ std_normal();
  s       ~ exponential(2.0);

  for(i in 1:N){
    y[i] ~ wrapped_cauchy(mu_vec[i], gamma_vec[i]);
  }

}
generated quantities{
  vector[N] log_lik;

  // Calculate log posterior
  for(i in 1:N){
    log_lik[i] = wrapped_cauchy_lpdf(y[i]|mu_vec[i], gamma_vec[i]);
  }
}
