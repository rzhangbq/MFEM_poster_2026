---
marp: true
paginate: true
math: katex
html: true
title: Particle-in-cell in MFEM
author: Rushan Zhang
header: '![](fig/GTExtended_Navy.png)'
footer: MFEM Workshop 2026 · Particle-in-cell in MFEM
style: |
  .small-text { font-size: 0.68em; line-height: 1.25; }
  .medium-text { font-size: 0.88em; }
  .columns-l { width: 38%; float: left; margin-right: 2%; }
  .columns-r { width: 58%; float: right; }
  header {
    left: auto; right: auto; top: auto; bottom: auto;
    left: 20px; top: 16px;
  }
  header img { height: 44px; width: auto; }
  header, footer, section::after { z-index: 2; }
  footer {
    left: auto; right: auto; top: auto; bottom: auto;
    left: 20px; bottom: 16px; top: auto; right: auto;
    font-size: 14px; color: #667085;
  }
  .qr-box {
    position: absolute;
    top: 12px;
    right: 18px;
    width: 86px;
    text-align: center;
    z-index: 3;
  }
  .qr-box img {
    width: 86px;
    height: 86px;
    display: block;
    margin: 0 auto;
    background: transparent;
    mix-blend-mode: multiply;
  }
  .qr-box .qr-label {
    font-size: 12px;
    color: #667085;
    line-height: 1.15;
    margin-top: 2px;
  }
  section {
    font-family: "Avenir Next", "Helvetica Neue", Arial, sans-serif;
    color: #172033;
    background-color: #ffffff;
    position: relative;
  }
  section > * { position: relative; z-index: 1; }
  img.bg-logo {
    position: absolute;
    top: 0;
    right: 0;
    width: auto;
    height: 100%;
    object-fit: contain;
    object-position: left center;
    clip-path: inset(0 50% 0 0);
    transform: translateX(50%);
    opacity: 0.3;
    z-index: 0;
    pointer-events: none;
  }
  h1, h2, h3 { color: #12355b; letter-spacing: -0.02em; }
  strong { color: #006d77; }
  .step { color: #006d77; font-weight: 700; }
  .equation-box {
    background: #eef6fa;
    border: 2px solid #b8dbe5;
    border-radius: 10px;
    padding: 2px 10px;
    margin: 4px 0 6px;
  }
  .caption { font-size: 0.62em; color: #475467; margin: 0 0 0.35em; line-height: 1.25; }
  .columns-l h3, .columns-r h3 { margin: 0 0 0.18em; font-size: 1.15em; }
  .columns-l p, .columns-r p { margin: 0.18em 0; }
  .columns-r img { max-height: 280px; width: 100%; object-fit: contain; vertical-align: top; }
  .columns-r img.filter-fig { max-height: 380px; }
---

<img class="bg-logo" src="fig/MFEM_logo.png" alt="" />
<div class="qr-box">
<img src="fig/qr-pic.png" alt="electrostatic-pic.cpp on GitHub" />
<div class="qr-label">Code</div>
</div>

**MFEM Workshop 2026**
# Particle-in-cell in MFEM
<div class="medium-text">
Rushan Zhang<sup>1</sup> <span class="small-text">(rzhangbq@gatech.edu)</span>, Joseph Signorelli<sup>2</sup>, Ketan Mittal<sup>3</sup>, Tzanio Kolev<sup>3</sup>, Qi Tang<sup>1</sup>
</div>
<div class="small-text">
<em><sup>1</sup>Georgia Institute of Technology, <sup>2</sup>University of Illinois Urbana-Champaign, <sup>3</sup>Lawrence Livermore National Laboratory</em>
</div>

### Highlights
- Electrostatic **PIC** on MFEM particle tracing: particles deposit charge, the mesh field pushes them back
- Compatible gradient $\mathrm{CG}\xrightarrow{\nabla_h}\mathrm{ND}$ and **OrthoSolver** for periodic Poisson
- **Biharmonic-heat** shape function: a mesh-compatible low-pass filter applied by solving $u_t+\kappa\Delta^2 u=0$

---

<img class="bg-logo" src="fig/MFEM_logo.png" alt="" />
<div class="qr-box">
<img src="fig/qr-pic.png" alt="electrostatic-pic.cpp on GitHub" />
<div class="qr-label">Code</div>
</div>

<div class="columns-l">

### One PIC time step in MFEM
<div class="small-text">

$$\text{particles}\xrightarrow{\text{deposit}}\text{field}\xrightarrow{\text{push}}\text{particles}$$

<span class="step">1.</span> **Deposit charge.** 
For $\varphi\in H^1(\Omega)$, assemble $e\sum_p\varphi(\mathbf x_p)$.

<span class="step">2.</span> **Solve Poisson.** 
`OrthoSolver` removes the periodic nullspace.

<div class="equation-box">

$\displaystyle\epsilon_0\langle\nabla\varphi,\nabla\phi\rangle=e\sum_p\varphi(\mathbf x_p)-en_0\int_\Omega\varphi.$

</div>

<span class="step">3.</span> **Compute field.** 
$\langle\mathbf v,\mathbf E+\nabla\phi\rangle=0$ in $H(\mathrm{curl})$.

<span class="step">4.</span> **Gather field.** 
Interpolate $\mathbf E$ at each $\mathbf x_p$.

<span class="step">5.</span> **Leapfrog push.**
<div class="equation-box">

$$\begin{aligned}
\mathbf p_p^{t+\frac12\Delta t}&=\mathbf p_p^{t-\frac12\Delta t}+e\mathbf E^t(\mathbf x_p^t)\Delta t,\\
\mathbf x_p^{t+1}&=\mathbf x_p^t+\mathbf p_p^{t+\frac12\Delta t}\Delta t/m_p.
\end{aligned}$$

</div>

<span class="step">6.</span> **Redistribute.** 
Exchange particles that cross MPI ranks.

</div>
</div>
<div class="columns-r">

### Low-pass shape function
<div class="small-text">

The shape function is the biharmonic heat kernel at time $\tau$:

$$s_{\mathbf{x}}(\mathbf{x})=E(\mathbf{x},\tau),\qquad \hat{E}(\mathbf{k},\tau)=e^{-\kappa(2\pi/L)^4\|\mathbf{k}\|^4\tau}.$$

Applying $s_{\mathbf{x}}$ is equivalent to convolving the Dirac charge (and the potential) with that kernel:

<div class="equation-box">

$$\rho=s_{\mathbf{x}}*\rho_\delta,\qquad \phi_s=s_{\mathbf{x}}*\phi,\qquad \mathbf{E}_p=-\nabla\phi_s(\mathbf{x}_p).$$

</div>

</div>
<img class="filter-fig" src="figs/filter_comparison.png" alt="Mode comparison of delta and Green shape functions" />
</div>
