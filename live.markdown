---
layout: live
title:
permalink: /live
---
The discontinuous Galerkin method for sequences of earthquakes and aseismic slip
--------------------------------------------------------------------------------
**Carsten Uphoff**, Dave May, Alice-Agnes Gabriel


<div class="columns_wrap">
    <div class="column1">
        <h3>SEAS modelling</h3>
        <img src="{{ "/assets/img/seas_2.png" | relative_url }}">
    </div>
    <div class="column2">
        <h3>Method</h3>
<img src="{{ "/assets/img/cosine_variable.png" | relative_url }}" style="float: right; height: 35vh; margin-right: 2em">
<div markdown="1">
1. Symmetric Interior Penalty Galerkin
2. Curvilinear simplex meshes (**2D** = triangles, **3D** = tetrahedra)
3. Sub-cell material resolution
4. Adaptive Runge-Kutta in time
</div>
<img src="{{ "/assets/img/regalbrett.png" | relative_url }}" style="float: right; height: 18vh; margin-right: 2em">
    </div>
    <div class="column1">
        <h3>High-order pays off</h3>
        <img src="{{ "/assets/img/seas_tandem_p1_f0436cb_3.png" | relative_url }}">
    </div>
    <div class="column2">
        <h3>High-performance computing</h3>
<div markdown="1">
Need to solve $$A\bm{u}=\bm{b}$$ millions of times.
1. P-Multigrid
2. Matrix-free operator > 40% peak
3. Dimensional reduction: Discrete Green's function

$$
    A\bm{u} = \bm{b} = \bm{b}_0 + \bm{b}_D t + B\bm{S}
$$

where $$\bm{u} \in DN$$, $$\bm{S} \in (D-1)n$$, and $$n \ll N$$

</div>
    </div>
</div>

<h2 class="virtual-display-link">
Check out the virtual display at <a href="https://tear-erc.github.io/tandem-egu21/">https://tear-erc.github.io/tandem-egu21/</a>
</h2>
