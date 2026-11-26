# Complete-QNMs

This repository accompanies the *Complete quasinormal modes of Type-D black holes* series and covers four black hole families: Schwarzschild, Kerr, Reissner–Nordström (RN), and Kerr–Newman (KN). Changkai Chen develops and maintains the datasets and visualization programs.

## Contents

| Black hole | Dataset and programs | Coverage |
| --- | --- | --- |
| Schwarzschild | [Schwarzschild/S2](Schwarzschild/S2) | Gravitational QNM spectra for ell = 2, 3, with MATLAB visualization. |
| Kerr | [Kerr/S2/Kerr_Spectrum](Kerr/S2/Kerr_Spectrum) | Nonextremal and extremal gravitational spectra for ell = 2, 3 and parent overtones 0–41. Includes MATLAB, Mathematica, and Python programs. |
| Reissner–Nordström (RN) | [Reissner-Nordstrom](Reissner-Nordstrom) | Gravitational spectra from zero to extremal charge for ell = 2, 3 and parent overtones 0–41. Includes MATLAB, Mathematica, and Python programs. |
| Kerr–Newman (KN) | Dataset not yet available | Included in the project scope. |

## Kerr spectra, including extremal Kerr

`Kerr/S2/Kerr_Spectrum/Kerr_spectrum.xlsx` combines nonextremal samples and a/M = 1 endpoints in one workbook. Each Schwarzschild parent overtone has its own worksheet, ordered by ell, m, and a/M. The `endpoint_type` column distinguishes isolated extremal QNM roots from zero-damping accumulation limits. Frequency and spin values are stored as text to retain all source digits.

The earlier L2, L3, and L4 datasets and programs are preserved in [Kerr/S2/Old_Version](Kerr/S2/Old_Version).

- **MATLAB:** open `plot_qnm.m`, set `ell` and `overtone`, and run the script. The original plotting style and datatip configuration are retained.
- **Mathematica:** load `plot_qnm.wl`, then run `PlotKerrQNM[2,0]`.
- **Python:** run `python plot_qnm.py --ell 2 --n 0`.

## Reissner–Nordström spectra

`Reissner-Nordstrom/RN_spectrum.xlsx` contains one worksheet per overtone, with columns `ell`, `hat_n`, `Q`, `omega_re`, and `omega_im`. Additional roots without an assigned parent among the first 42 families are excluded.

- **MATLAB:** `plot_RN` for all families or `plot_RN(2,8)` for one family.
- **Mathematica:** load `plot_RN.wl`, then run `RNPlot[]` or `RNPlot[2,8]`.
- **Python:** `python plot_RN.py` or `python plot_RN.py --ell 2 --n 8`.

## How to cite

Please cite the paper corresponding to the dataset you use.

1. **Schwarzschild and Kerr.** [Phys. Rev. D 112, 103036 (2025)](https://doi.org/10.1103/f8m8-vr4l) · [arXiv:2506.14635](https://arxiv.org/abs/2506.14635)
2. **Extremal Kerr.** [arXiv:2610.39095](https://arxiv.org/abs/2610.39095)
3. **Reissner–Nordström.** [arXiv:2611.24647](https://arxiv.org/abs/2611.24647)

```bibtex
@article{Chen:2025sbz,
  author        = {Chen, Changkai and Jing, Jiliang and Cao, Zhoujian and Wang, Mengjie},
  title         = {{Complete quasinormal modes of type-D black holes}},
  journal       = {Phys. Rev. D},
  volume        = {112},
  number        = {10},
  pages         = {103036},
  year          = {2025},
  doi           = {10.1103/f8m8-vr4l},
  eprint        = {2506.14635},
  archivePrefix = {arXiv},
  primaryClass  = {gr-qc}
}

@article{Chen:2026hjt,
  author        = {Chen, Changkai and Zhang, Xiaohua and Cao, Zhoujian and Jing, Jiliang},
  title         = {{Complete quasinormal modes of Type-D black holes. II. Extremal Kerr black holes}},
  month         = {10},
  year          = {2026},
  eprint        = {2610.39095},
  archivePrefix = {arXiv},
  primaryClass  = {gr-qc}
}

@article{Chen:2026swp,
  author        = {Chen, Changkai and Zhang, Xiaohua and Cao, Zhoujian and Jing, Jiliang},
  title         = {{Complete quasinormal modes of Type-D black holes. III. Reissner-Nordstr{\"o}m spectra from zero to extremal charge}},
  month         = {11},
  year          = {2026},
  eprint        = {2611.24647},
  archivePrefix = {arXiv},
  primaryClass  = {gr-qc}
}
```
