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

  vector<lower=-pi(), upper=pi()>[N] y; // Angles
}
parameters{
  vector[2] mu_raw[P,E];
  vector[C] alpha_C;
  vector[P] alpha_P;
  vector[E] alpha_CE_raw[C];
  vector[E] tau_E;
  cholesky_factor_corr[E] L;
}
transformed parameters{
  vector[E] alpha_CE[C];

  for(i in 1:C){
    alpha_CE[i] = diag_pre_multiply(exp(tau_E), L) * alpha_CE_raw[i];
  }

}
model{
  alpha_P ~ std_normal();
  tau_E   ~ std_normal();
  alpha_C ~ std_normal();
  L       ~ lkj_corr_cholesky(2.0);

  for(i in 1:C){
    alpha_CE_raw[i] ~ std_normal();
  }

  for(i in 1:P){
    for(j in 1:E){
      mu_raw[i,j]   ~ bundt();
    }
  }

  for(i in 1:N){
    y[i] ~ wrapped_cauchy(atan2(mu_raw[participant_idx[i], electrode_idx[i], 1], mu_raw[participant_idx[i], electrode_idx[i], 2]),
                          -log(inv_logit(alpha_C[condition_idx[i]] + alpha_CE[condition_idx[i], electrode_idx[i]] + alpha_P[participant_idx[i]])));
  }
}
generated quantities{
  vector[C] r_C;

  // Variance contribution when looking at condition alone
  for(i in 1:C){
    r_C[i] = 1 - inv_logit(alpha_C[i]);
  }
}
