---
layout: page
title: SEAS modelling
permalink: /seas
---

$$
\begin{aligned}
    -\frac{\partial\sigma_{ij}(\bm{u})}{\partial x_j} &= f_i & \text{ in } & \Omega\\
    \sigma_{ij}(\bm{u}) &= c_{ijkl}\epsilon_{kl}(\bm{u}) & \text{ in } & \Omega\\
    u_i &= g_i& \text{ on } & \Gamma_D \\
    \sigma_{ij}(\bm{u})n_j &= 0 & \text{ on } & \Gamma_N \\
    \llbracket u_j\rrbracket n_j &= 0 & \text{ on } & \Gamma_F \\
    (\delta_{ij}-n_in_j)\llbracket u_j\rrbracket &= S_i & \text{ on } & \Gamma_F
\end{aligned}
$$

$$
\begin{aligned}
    \frac{d\psi}{dt} &= g(|V|,\psi)\\
    \frac{dS_i}{dt} &= V_i\\
    -\tau_i &= \sigma_nf(|V|,\psi) V_i / |V| + \eta V_i
\end{aligned}
$$

where $$\tau_i = \tau_i^0 + (\delta_{ij}-n_in_j)\sigma_{jk}(\bm{u})n_k$$
and $$\sigma_n = \sigma^0 + n_i\sigma_{ij}(\bm{u})n_j$$.


![seas]({{ 'assets/img/seas.svg' | relative_url }})
