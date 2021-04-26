---
layout: page
title: Verification
permalink: /verification
---

Here, we verify that our DG implementation achieves high-order convergence.
We first describe several test problems for the linear elasticity solver,
present a manufactured test problem for antiplane shear motion second,
and lastly compare against the SCEC SEAS project.
All test cases are given and can be reproduced from the
[github repository](https://github.com/TEAR-ERC/tandem/tree/seas/examples).

1. TOC
{:toc}

Static test problems
====================

An overview of the problems presented here is given in the following:

<div class="columns_wrap">
<div class="column33" markdown="1">
**cosine_variable**

![cosine_variable]({{ '/assets/img/cosine_variable.png' | relative_url }}){: width="80%" }

* Manufactured solution
* Heterogeneous material
* Curved boundary (annulus)
</div>
<div class="column33" markdown="1">
**embedded_half**

![embedded_half]({{ '/assets/img/embedded_half.png' | relative_url }}){: width="80%" }

* Slip boundary condition
* Mesh is warped by displacement 
</div>
<div class="column33" markdown="1">
**singular**

![singular]({{ '/assets/img/singular.png' | relative_url }}){: width="80%" }

* Poisson problem from {% cite riviere2008 %}
* Sharp material contrast (checkerboard)
* Singular gradient at centre
</div>
</div>

The following log-log plot shows result of a convergence study on the above test problems,
where $$P$$ is the maximum polynomial degree.

![]({{ '/assets/img/poisson_static_p1_q20_99b54da.png' | relative_url }})

We obtain the expected order of convergence for all three test problems, which is
($$P+1$$) for the first two problems, and 1 for the third problem {% cite riviere2008 %},
due to a singular gradient at the origin.
For problem *embedded_half* the solution is a polynomial of degree 7.
Therefore, we reach the minimum error already with the highest spatial resolution for
degrees $$P=7,8$$, as the solution is element of the respective finite element spaces.
For problem *singular* we can only obtain order 1 convergence but still obtain a lower error
with higher order schemes.

Antiplane shear motion
======================

There are no known analytic solutions to a SEAS-type problem with rate and state friction.
We therefore use a [manufactured solution](https://github.com/TEAR-ERC/tandem/blob/seas/examples/tandem/2d/mms1.lua) for antiplane shear motion to test our implementation, which is very similar a manufactured solution of
Erickson and Dunham {% cite erickson2014 %}.
The following figure shows a convergence study.
We choose the adaptive Dormand-Prince scheme for time integration, which is a fifth order Runge-Kutta
scheme (using 6 right-hand side evaluations) with the fourth order embedded method.

![]({{ '/assets/img/seas_tandem_p1_f0436cb.png' | relative_url }}){: width="80%" .center-image }

The results show that our method achieves high-order convergence for SEAS problems, too,
although the convergence order is apparently limited by the time integrator.

Plotting the error against a metric of work, which is
the number of degrees of freedom times the number of time-steps times the number of Runge Kutta
stages, we observe that high-order clearly pays off:

![]({{ '/assets/img/seas_tandem_p1_f0436cb_2.png' | relative_url }}){: width="80%" .center-image }

SCEC SEAS project comparison
===========================
The SCEC SEAS project {% cite erickson2020 %} aims to verify SEAS models by comparing codes of
independent groups using different methods on well-defined benchmark problems.
A [web-based platform](https://strike.scec.org/cvws/seas/)
is provided which allows to upload and compare solutions.
Tandem solutions for problems BP1-QD and BP3-QD match solutions of other codes very well
and can be [compared online](https://strike.scec.org/cvws/seas/). 

For example, below we show the slip-rate time-series of the BP1-QD problem for the station located at 7.5 km depth.

![bp1_comparison]({{ '/assets/img/bp1.svg' | relative_url }}){: width="100%" }

An advantage of using a discontinuous Galerkin scheme is that meshes can be statically refined
and we use high-order function spaces.
For example, the mesh used in the comparison for BP3-QD has an on-fault resolution of 250 m and
coarsens to 40 km edge-length towards the far boundary, cf. below figure.
The on-fault resolution is 10x larger than the cell size of 25 m recommended in the benchmark description.

![bp3_mesh]({{ '/assets/img/bp3_mesh.png' | relative_url }}){: width="80%" .center-image }




References
==========
{% bibliography --cited %}
