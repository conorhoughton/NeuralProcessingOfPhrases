functions{
  real wrapped_cauchy_rng(real mu, real gamma){
    real z = cauchy_rng(mu, gamma);
    return(atan2(sin(z), cos(z)));
  }
}
data{
  int N; // Number of data points
  int P; // Number of participants
  int C; // Number of conditions
  int E; // Number of electrodes
  int T; // Number of trials
  vector<lower=0, upper=1>[C] a_cv;

  int<lower=1, upper=P> participant_idx[N];
  int<lower=1, upper=E> electrode_idx[N];
  int<lower=1, upper=C> condition_idx[N];
  real<lower=2> nu_sim;
  real<lower=0> sig;
  real<lower=0> tau;
}
transformed data{
  real<lower=0>sig2 = sig;
}
generated quantities{
  //vector[C]          a_cv_sim; // Baseline condition effects
  vector<lower=0>[C] s_p_sim; // Standard deviation of participant slopes
  vector<lower=0>[C] s_e_sim; // Standard deviation of electrode slopes

  s_p_sim[1] = sig;
  s_p_sim[2] = sig2;
  s_e_sim = rep_vector(tau, C);

  //for(i in 1:C){
    //a_cv_sim[i]  = beta_rng(3,2);
    //s_p_sim[i]   = abs(normal_rng(0, 0.5));
    //s_e_sim[i]   = abs(normal_rng(0, 0.5));
  //}

  // Cholesky factor of the correlation matrix
  matrix[C,C] Omega_p_sim = lkj_corr_rng(C, 2.0);

  // Pooling slopes for participants and electrodes
  vector[C]     a_p_sim[P];
  vector[C]     a_e_sim[E];

  // Electrodes (effects per conditon) all p-pooled within condition
  for(i in 1:E){
    for(j in 1:C){
      a_e_sim[i,j] = normal_rng(0, s_e_sim[j]);
    }
  }

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
    theta_sim[i] = logit(a_cv[condition_idx[i]]) + a_e_sim[electrode_idx[i],condition_idx[i]] + a_p_sim[participant_idx[i],condition_idx[i]];
    gamma_sim[i] = -log( 1- inv_logit(theta_sim[i]));
    for(j in 1:T){
      y_sim[i,j] = wrapped_cauchy_rng(mean_angle_sim[i], gamma_sim[i]);
    }
  }
}
