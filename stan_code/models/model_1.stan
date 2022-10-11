// User defined probability functions (up to constant)
functions{
    real wrapped_cauchy_lpdf(vector y, real mu, real gamma){
      return sum(log(sinh(gamma)) - log(cosh(gamma) - cos(y-mu)));
    }
    real inv_gaussian_lpdf(vector y, real mu, real lambda){
      return sum(0.5*log(lambda) - 1.5*log(y) - (lambda*square((y-mu))) ./ (2*mu^2*y));
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
  // Condition params
  vector[C] a_c;    // Baseline condition effects

  // Pooling slopes for participants and electrodes
  vector[C]               a_p_raw[P];  // Participants
  vector<lower=0>[C]      s_p;         // Standard deviation of participant slopes

  vector[C]               a_e_raw[E];  // Electrodes
  vector<lower=0>[C]      s_e;         // Standard deviation of electrode

  // Angle
  vector[2] xy_uncnstr[N];
}
transformed parameters{
  // Independent params
  vector[C]      a_cv;

  // Pooling slopes for participants and electrodes
  vector[C]   a_p[P];
  vector[C]   a_e[E];

  // Vectorisations
  vector[N] mean_angle;
  vector[N] vector_len;
  vector[N] theta;
  vector[N] gamma;

  a_cv      = inv_logit(a_c);

  for(i in 1:P){
    a_p[i] = s_p .* a_p_raw[i];
  }

  for(i in 1:E){
    a_e[i] = s_e .* a_e_raw[i];
  }

  for(i in 1:N){
    vector_len[i] = sqrt(dot_self(xy_uncnstr[i]));
    mean_angle[i] = atan2(xy_uncnstr[i,2], xy_uncnstr[i,1]);
    theta[i]      = a_c[condition_idx[i]] + a_p[participant_idx[i],condition_idx[i]] + a_e[electrode_idx[i],condition_idx[i]];
  }

  gamma = -log( 1- inv_logit(theta) );
}
model{

  a_cv ~ beta(3,2);
  target += a_c - 2*log(exp(a_c) + 1);

  s_p ~ normal(0, 0.5);
  s_e ~ normal(0, 0.5);

  for(i in 1:P){
    a_p_raw[i] ~ std_normal();
  }

  for(i in 1:E){
    a_e_raw[i] ~ std_normal();
  }

  vector_len ~ gamma(10, 10);
  target += -log(vector_len);

  // Observations
  for(i in 1:N){
    y[i] ~ wrapped_cauchy(mean_angle[i], gamma[i]);
  }
}
