functions{
  real wrapped_cauchy_rng(real mu, real gamma){
    real z = cauchy_rng(mu, gamma);
    return(atan2(sin(z), cos(z)));
  }
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
  real<lower=2> nu_sim;
}
transformed data{
  vector[C]          a_cv_sim; // Baseline condition effects
  vector<lower=0>[C] s_p_sim; // Standard deviation of participant slopes
  vector<lower=0>[C] s_e_sim; // Standard deviation of electrode slopes
  real mrl_diff_sim;

  for(i in 1:C){
    a_cv_sim[i]  = beta_rng(3,2);
    s_p_sim[i]   = abs(normal_rng(0, 0.5));
    s_e_sim[i]   = abs(normal_rng(0, 0.5));
  }

  mrl_diff_sim = (1-a_cv_sim[1]) - (1-a_cv_sim[2]);

  // Cholesky factor of the correlation matrix
  matrix[C,C] Omega_p_sim = lkj_corr_rng(C, 2.0);

  // Pooling slopes for participants and electrodes
  vector[C]     a_p_sim[P];
  vector[C]     a_e_sim[E];
  //real<lower=0> nu_sim;

  // Electrodes (effects per conditon) all p-pooled within condition
  for(i in 1:E){
    for(j in 1:C){
      a_e_sim[i,j] = normal_rng(0, s_e_sim[j]);
    }
  }

  //nu_sim = gamma_rng(2, 0.1) + 2; // Not correct

  // Participant effects per condition (MV)
  for(i in 1:P){
    a_p_sim[i] = multi_student_t_rng(nu_sim, rep_vector(0,C), quad_form_diag(Omega_p_sim, s_p_sim));
  }

  vector[N] mean_angle_sim; // No HMC --> no boundary issues

  for(i in 1:N){
    mean_angle_sim[i] = uniform_rng(-pi(), pi());
  }

  vector[N] theta_sim;
  vector[N] gamma_sim;
  vector[T] y_sim[N];

  // parameters that are deterministic and data
  for(i in 1:N){
    theta_sim[i] = logit(a_cv_sim[condition_idx[i]]) + a_e_sim[electrode_idx[i],condition_idx[i]] + a_p_sim[participant_idx[i],condition_idx[i]];
    gamma_sim[i] = -log( 1- inv_logit(theta_sim[i]));
    for(j in 1:T){
      y_sim[i,j] = wrapped_cauchy_rng(mean_angle_sim[i], gamma_sim[i]);
    }
  }
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
  real mrl_diff;

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
    //a_p[i] = sigma_L_p * a_p_raw[i] ./ sqrt(phi);
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
  mrl_diff = (1 - a_cv[1]) - (1 - a_cv[2]);
}
model{

  nu ~ gamma(2, 0.1);
  phi ~ inv_gamma(nu*0.5,nu*0.5);
  //phi ~ gamma(nu*0.5,nu*0.5);

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
    y_sim[i] ~ wrapped_cauchy(mean_angle[i], gamma[i]);
  }
}
generated quantities{
  array[C] int<lower=0, upper=1> main_effect_ranks;
  array[E] int<lower=0, upper=1> electrode_effect_ranks;
  array[P] int<lower=0, upper=1> participant_effect_ranks;
  array[C] int<lower=0, upper=1> participant_sd_ranks;
  array[C] int<lower=0, upper=1> electrode_sd_ranks;
  int<lower=0, upper=1> nu_ranks;
  int<lower=0, upper=1> mrl_diff_ranks;

  // first two are effects
  for(i in 1:C){
    main_effect_ranks[i]    = a_cv[i] < a_cv_sim[i];
    participant_sd_ranks[i] = s_p[i]  < s_p_sim[i];
    electrode_sd_ranks[i]   = s_e[i]  < s_e_sim[i];
  }

  for(i in 1:E){
    electrode_effect_ranks[i] = a_e[i,1] < a_e_sim[i,1];
  }

  for(i in 1:P){
    participant_effect_ranks[i] = a_p[i,1] < a_p_sim[i,1];
  }

  // dof
  nu_ranks = nu < nu_sim;
  mrl_diff_ranks = mrl_diff < mrl_diff_sim;
}
