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
A very efficient and scalable solver is therefore mandatory.


1. TOC
{:toc}

Flexible solvers using PETSc
============================

Our implementation is MPI parallel and interfaces to PETSc which allows us to efficiently
prototype solvers {% cite petsc-web-page petsc-user-ref petsc-efficient %}.
We focus on the following three types of solvers:

1. Direct sparse LU (e.g. MUMPS, PARDISO)
2. GMRES with two-level deflation preconditioner, where the eigendecomposition is computed via Randomised Linear Algebra
3. Conjugate gradients with P-multigrid preconditioner

We present small-scale numerical experiments for a
[**3D** elasticity problem on the unit box](https://github.com/TEAR-ERC/tandem/blob/3685e76425da4ae13b190f22d301b70acb416252/examples/elasticity/3d/cosine.lua).
The polynomial degree is fixed to $$P=6$$ in all experiments and the relative tolerance is set
to $$10^{-8}$$.
The experiments are executed on an AMD EPYC 7662 processor.

Sparse LU (MUMPS)
----------------

We obtained the following results on a single core:

| Resolution|   DOFs| Setup time| Solve time|
|----------:|------:|----------:|----------:|
|      1.000|   1260|    0.1505s|  0.001098s|
|      0.500|  10080|     3.649s|   0.02512s|
|      0.250|  80640|     159.9s|    0.5515s|
|      0.125| 645120|      6545s|     6.469s|
{: .autowidth }

The LU decomposition requires a huge setup time.
Moreover, we observe that the LU decomposition requires more than
100 GB of memory on the finest grid.
Nevertheless, we can re-use the LU millions of times in a SEAS simulation, such that
LU is still competitive due to its low solve time.

Two-level deflation
-------------------

The LU decomposition will very likely not scale to very large problems due to its huge memory
requirement and its serial nature.
One way to scale direct methods are iterative domain decomposition methods, where a direct solver is
used to solve the elasticity problem on subdomains.

Here, we test a multiplicative two-level method, where on the first level the smallest eigenvalues
are deflated, and on the second level an additive Schwarz method is used (PC type asm in PETSc).
In the following table of results, 64 eigenvalues are deflated, where the eigenvalues are
obtained via a randomised linear algebra.


| Ranks| Resolution| Setup time| Solve time| Iterations|
|-----:|----------:|----------:|----------:|----------:|
|     1|       0.25|     542.8s|    0.7187s|          1|
|     2|       0.25|     573.8s|     2.643s|          6|
|     4|       0.25|      1266s|     6.738s|         14|
|     8|       0.25|      1666s|     25.98s|         16|
|    16|       0.25|      2184s|     40.11s|         20|
|    32|       0.25|      1489s|     28.67s|         23|
|    64|       0.25|      1643s|     46.49s|         20|
{: .autowidth }

The solve times are not competitive to sparse LU, although the total time for a single solve
is lower.



P-multigrid
-----------

In the P-multigrid method coarse grids are constructed by reducing the polynomial degree.
In this experiment, we use P-levels 6, 3, and 1, and use the sparse LU solver on the coarsest grid. 
On a single core we obtain the following results:

| Resolution|    DOFs| Setup time| Solve time| Iterations|
|----------:|-------:|----------:|----------:|----------:|
|     1.0000|    1260|    0.2317s|     0.146s|         11|
|     0.5000|   10080|     2.521s|     2.179s|         19|
|     0.2500|   80640|     23.51s|     25.46s|         22|
|     0.1250|  645120|     195.6s|     171.2s|         22|
|     0.0625| 5160960|      1717s|      1111s|         21|
{: .autowidth }

We observe that the number of iterations stays almost constant (except for the smallest case,
where fewer iterations are required).

The P-multigrid is well-suited for parallelisation.
We scale the $$h=0.125$$ mesh from 1 to 32 cores in the following experiment
for two different implementation: Assembled (AS) uses assembled matrices on each level,
Matrix-free (MF) uses a matrix-free operator application on the finest level.


|Type | Variable        |      1|      2|      4|      8|     16|     32|
|:----|:----------------|------:|------:|------:|------:|------:|------:|
|AS   |solve            | 271.1s| 148.9s|  87.1s| 72.41s|  72.3s| 40.15s|
|     |speed-up         |     1x|   1.8x|   3.1x|   3.7x|   3.7x|   6.8x|
|MF   |solve            | 169.9s| 100.6s| 48.69s|  26.1s| 16.96s| 9.843s|
|     |speed-up         |     1x|   1.7x|   3.5x|   6.5x|    10x|    17x|
|     |fine-grid GFLOPS |   21.5|   42.6|   83.7|    162|    328|    635|

We observe that the matrix-free variant outperforms the assembled variant.
While an operator application with the matrix-free variant requires more floating point operations
than an operator application with an assembled matrix, it can make better use of modern hardware,
which is strongly biased towards compute-intensive workloads.

The performance of the matrix-free operator is measured in isolation, by applying the operator
a hundred times on random data.
On a single core we measure 21.5 GFLOPS, which corresponds to 41--67% of the theoretical peak
performance (in the frequency range of 2--3.3 GHz). 
On 32 cores we measure 635 GFLOPS or 38--64% of the theoretical peak.
The matrix-free operator is implemented using Yet Another Tensor Toolbox {% cite Uphoff2020 %}.

The coarse grid solve is likely the bottleneck of P-multigrid when scaling the method
to more cores.
In future work, we are going to consider other coarse grid solvers, such as the two-level
deflation method or algebraic multi-grid.


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
