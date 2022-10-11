// User defined probability functions - wrapped Cauchy (up to a constant)
functions{
    real wrapped_cauchy_lpdf(vector y, real mu, real gamma){
      return sum(log(sinh(gamma)) - log(cosh(gamma) - cos(y-mu)));
    }
}
data{
  int N; // Number of data points
  int P; // Number of participants
  int C; // Number of conditions
  int E; // Number of electrodes
  int T; // Number of trials

  int<lower=1, upper=P> participant_idx[N];
  int<lower=1, upper=E> electrode_idx[N];
  int<lower=1, upper=C> condition_idx[N];

  vector<lower=-pi(), upper=pi()>[T] y[N];
}
parameters{
  // Baseline condition effects
  vector[C] a_c;

  // Pooling slopes for participants and electrodes
  vector[C]               a_p_raw[P];
  vector[C]               a_e_raw[E];

  vector<lower=0>[C]      s_p; // Standard deviation of participant slopes
  vector<lower=0>[C]      s_e; // Standard deviation of electrode slopes

  cholesky_factor_corr[C] L_p; // Cholesky factor of the correlation matrix

  real<lower=0> phi;
  real<lower=2> nu; // Degrees of freedom

  // Angle
  vector[2] xy_uncnstr[N];
}
transformed parameters{
  // Independent params
  vector[C]      a_cv;

  // Pooling slopes for participants and electrodes
  vector[C]   a_p[P]; // Participants
  vector[C]   a_e[E]; // Electrodes
  matrix[C,C] sigma_L_p;

  // Vectorisations
  vector[N] mean_angle;
  vector[N] vector_len;
  vector[N] theta;
  vector[N] gamma;

  a_cv      = inv_logit(a_c);
  sigma_L_p = diag_pre_multiply(s_p, L_p);

  for(i in 1:P){
    a_p[i] = sigma_L_p * a_p_raw[i] * sqrt(phi);
  }

  for(i in 1:E){
    a_e[i] = s_e .* a_e_raw[i];
  }

  for(i in 1:N){
    vector_len[i] = sqrt(dot_self(xy_uncnstr[i]));
    mean_angle[i] = atan2(xy_uncnstr[i,2], xy_uncnstr[i,1]);
    theta[i]      = a_c[condition_idx[i]] + a_e[electrode_idx[i],condition_idx[i]] + a_p[participant_idx[i],condition_idx[i]];
  }

  gamma = -log( 1- inv_logit(theta) );
}
model{

  nu ~ gamma(2, 0.1);
  phi ~ inv_gamma(nu*0.5,nu*0.5);

  a_cv ~ beta(3,2);
  target += a_c - 2*log(exp(a_c) + 1); // Jacobian adjustment

  L_p ~ lkj_corr_cholesky(2.0);
  s_p ~ normal(0, 0.5);
  s_e ~ normal(0, 0.5);

  for(i in 1:P){
    a_p_raw[i] ~ std_normal();
  }

  for(i in 1:E){
    a_e_raw[i] ~ std_normal();
  }

  vector_len ~ gamma(10,10);
  target += -log(vector_len); // Jacobian adjustment

  // Observations
  for(i in 1:N){
    y[i] ~ wrapped_cauchy(mean_angle[i], gamma[i]);
  }
}
