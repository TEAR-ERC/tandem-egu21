---
layout: page
title: HPC
permalink: /hpc
---

SEAS problems are very expensive to solve. The most expensive of the
[proposed method]({{ '/method' | relative_url }})
is the solution of a linear system of equations.
Due to [high variability in time-step size]({{ '/seas#seas-example' | relative_url}})
and the potentially long simulated time of thousands of years, millions of time-steps
may be required, where each time-step needs several stages, i.e. multiple solves per time-step.
A very efficient solver and scalable is therefore mandatory.


1. TOC
{:toc}

Flexible solvers using PETSc
============================

Our implementation is MPI parallel and interfaces to PETSc which allows us to efficiently
prototype solvers {% cite petsc-web-page petsc-user-ref petsc-efficient %}.
We focus on the following three types of solvers:

1. Direct sparse LU (e.g. MUMPS, PARDISO)
2. GMRES with two-level deflation preconditioner, where eigenvalues and eigenvectors are obtained through a randomised algorithm
3. Conjugate gradients with P-multigrid preconditioner

Direct sparse solvers are inherently serial and consume large amounts of memory.
Nevertheless, they are still competitive as the LU decomposition needs to be done only once.

Our experiments indicate that the two-level deflation algorithm is weakly scalable,
but the number of eigenvectors needs to grow with number of ranks.
The latter might be a scalability bottleneck due to the high cost of computing eigenvectors.

A promising candidate is the P-multigrid method, as it may be combined with direct sparse solvers,
the two-level deflation preconditioner, and also algebraic multi-grid. In particular
with very high-orders the coarse-grid problem becomes very small in comparison to the finest grid,
e.g. for $$P=8$$ the number of dofs in the coarse grid problem is 45x smaller in 2D and 165x smaller in 3D.


Discrete Green's function
=========================

The major cost stems from solving the
[linear system $$A\bm{u}=\bm{b}$$]({{ '/method' | relative_url }}).
In the time-stepping loop, the right-hand side depends **linearly** on time and the slip-vector,
and may be written as following:

$$
    \bm{b} = \bm{b}_0 + \bm{b}_D t + B\bm{S}
$$

Note that the size of $$\bm{S}$$ is $$(D-1)n$$, $$D$$ being the dimension, $$n$$ being the number of
on-fault basis functions.

Moreover, on-fault traction depends linearly on displacement and can be written as

$$
    [\sigma_n(\bm{u}), \tau(\bm{u})] = C\bm{u},
$$

where $$C$$ is a $$Dn \times DN$$ matrix, $$N$$ being the number of basis functions in the domain.
Therefore, we may write the on-fault traction as following

$$
    [\sigma_n(\bm{u}), \tau(\bm{u})] = \underbrace{CA^{-1}\bm{b}_0}_{\bm{G}_0}
        + t\underbrace{CA^{-1}\bm{b}_D}_{\bm{G}_D}
        + \sum_{i=1}^{(D-1)n} \underbrace{CA^{-1}B\bm{e}_i}_{\bm{G}_i}S_i,
$$

where $$\bm{e}_i$$ is the i-th unit vector.
The vectors $$\bm{G}_0, \bm{G}_D, \bm{G}_1,\dots,\bm{G}_{(D-1)n}$$ can be precomputed
by solving the linear system of equations $$(D-1)n + 2$$ times.
As we only need the on-fault tractions in the time integrator, we can exchange the solve
of a sparse system with a $$DN \times DN$$ matrix with dense matrix multiplication of
size $$(D-1)n \times (D-1)n$$ and two AXPYs.
Hence, this approach is attractive if $$n \ll N$$ and the number of time-steps is very large.

*Disussion.* On the one hand:
1. The memory requirement of this approach are potentially huge, as an $$(D-1)n\times(D-1)n$$ matrix needs to be stored.
2. The pre-computation time is huge if $$n$$ is large.

On the other hand:
1. Pre-computation of the $$\bm{G}$$-vectors is embarassingely parallel.
2. The approach is simple to implement and orthogonal to solver or performance optimisation.
3. After pre-computation of the $$\bm{G}$$-vectors, the complexity of this method is comparable to the a boundary element method for non-planar fault geometry, but without the need for an analytic Green's function. That is, there is no limitation to "simple" material variations.
4. The time-to-solution for the full BP3-QD benchmark problem is reduced from about 1 week run-time to about 3 hours using this method.

References
==========

{% bibliography --cited %}
