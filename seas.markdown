---
layout: page
title: SEAS modelling
permalink: /seas
---

SEAS models capture the entire earthquake cycle, i.e. tectonic loading, nucleation, rupture,
and afterslip, within one physical model.
A fault is idealized as an infinitesimally thin fault surface embedded in linear elastic media,
and on-fault behaviour is described via laboratory-derived rate and state friction laws.
Friction couples the slip $$S$$, normal stress $$\sigma_n$$, and shear
traction $$\tau$$ on the fault surface $$\Gamma_F$$, cf. the following conceptual
illustration of a normal fault.

![normal_fault]({{ '/assets/img/normal_fault.svg' | relative_url }}){: .center-image }

The rate and state friction relations are given by

$$
\begin{aligned}
    -\tau_i &= \sigma_nf(|V|,\psi) V_i / |V| \\
    \frac{dS_i}{dt} &= V_i\\
    \frac{d\psi}{dt} &= g(|V|,\psi)
\end{aligned}
$$

The first equation states that shear traction is proportional to normal stress times a coefficient
of friction $$f$$, where $$f$$ depends on the slip-rate and a single state variable.
Moreover, slip-rate $$V$$ and shear stress $$\tau$$ are anti-parallel.
The evolution of state is controlled by $$g$$.

The friction equations are coupled through the equations of linear elasticity in the domain
$$\Omega$$, i.e.

$$
    -\frac{\partial\sigma_{ij}(\bm{u})}{\partial x_j} = 0.
$$

(Sums over indices appearing twice are implied.)
A slip boundary is imposed in the linear elasticity problem, that is,

$$
    \llbracket u_i\rrbracket = T_{ij}S_j \text{ on } \Gamma_F,
$$

where $$T_{ij}(\bm{n})$$ is a $$D \times (D-1)$$ matrix, $$D$$ being the space dimension,
which contains a tangential basis of a fault segment with normal **n**.

The linear elasticity problem omits modelling of seismic waves, which are relevant during an earthquake
but can be neglected otherwise.
In order to get a stable formulation, the outflow of energy due to seismic waves is approximated
with the damping term $$\eta V_i$$ in the frictional relation. {% cite rice1993 %}

$$
    -\tau_i = \sigma_nf(|V|,\psi) V_i / |V| \color{red} + \eta V_i
$$

Adding the constitutive relation, Dirichlet and Neumann boundary conditions, and the damping
term we get the following system of equations: 

<a name="seas-equations"></a>

<div class="columns_wrap">
<div class="column50" markdown="1">
**Linear elasticity with slip BC**

$$
\begin{aligned}
    -\frac{\partial\sigma_{ij}(\bm{u})}{\partial x_j} &= F_i & \text{ in } & \Omega\\
    \sigma_{ij}(\bm{u}) &= c_{ijkl}\epsilon_{kl}(\bm{u}) & \text{ in } & \Omega\\
    u_i &= g_i& \text{ on } & \Gamma_D \\
    \sigma_{ij}(\bm{u})n_j &= 0 & \text{ on } & \Gamma_N \\
    \llbracket u_i\rrbracket &= T_{ij}S_j & \text{ on } & \Gamma_F
\end{aligned}
$$

($$F$$: body force, $$c$$: stiffness tensor,
$$\delta$$: Kronecker symbol,
$$n$$: unit normal
)
</div>
<div class="column50" markdown="1">
**Rate and state friction on $$\Gamma_F$$**

$$
\begin{aligned}
    -\tau_i &= \sigma_nf(|V|,\psi) V_i / |V| + \eta V_i \\
    \frac{dS_i}{dt} &= V_i\\
    \frac{d\psi}{dt} &= g(|V|,\psi)\\
    \tau_i &= T_{ji}\sigma_{jk}(\bm{u})n_k \\
    \sigma_n &= n_i\sigma_{ij}(\bm{u})n_j
\end{aligned}
$$

($$T$$: $$(D-1)\times D$$, $$c$$: stiffness tensor,
$$\delta$$: Kronecker symbol,
$$n$$: unit normal
)
</div>
</div>


Although seismic waves are neglected, tectonic loading, nucleation, rupture, and afterslip
can be observed in a SEAS model:

<a name="seas-example"></a>

![seas]({{ '/assets/img/seas.svg' | relative_url }}){:width="100%"}

The above shows a 2D simulation of a normal fault (vertical axis) over 1500 years.
Slip profiles are plotted along the horizontal axis, and displaced by time in the
in-screen direction.
An earthquake (in red) occurs about every hundred years.

Time-steps vary strongly: In the interseismic phase time-steps of days to months are possible,
whereas in the coseismic phase time-steps in the order of milliseconds are required.


References
==========

{% bibliography --cited %}
