# Complete-QNMs
Complete Quasinormal Modes of Black Holes 

The dataset and code is developed and maintained by Changkai Chen.

The QNM dataset will be continuously updated.


# How to cite

@article{Chen:2025sbz,

    author = "Chen, Changkai and Jing, Jiliang and Cao, Zhoujian and Wang, Mengjie",
    
    title = "{Complete quasinormal modes of type-D black holes}",
    
    eprint = "2506.14635",
    
    archivePrefix = "arXiv",
    
    primaryClass = "gr-qc",
    
    doi = "10.1103/f8m8-vr4l",
    
    journal = "Phys. Rev. D",
    
    volume = "112",
    
    number = "10",
    
    pages = "103036",
    
    year = "2025"
    
}


## Extremal Kerr dataset

The updated Kerr dataset and plotting programs are available in [Kerr/S2/Kerr_Spectrum_20261126](Kerr/S2/Kerr_Spectrum_20261126). Earlier datasets remain in their original directories.

For the extremal Kerr results, please also cite:

```bibtex
@article{Chen:2026hjt,
    author = "Chen, Changkai and Zhang, Xiaohua and Cao, Zhoujian and Jing, Jiliang",
    title = "{Complete quasinormal modes of Type-D black holes. II. Extremal Kerr black holes}",
    eprint = "2610.39095",
    archivePrefix = "arXiv",
    primaryClass = "gr-qc",
    month = "10",
    year = "2026"
}
```

## Reissner–Nordström spectra

[Dataset and plotting programs](Reissner-Nordstrom/) for the first 42 gravitational overtone families at each of ell = 2 and 3. The workbook contains one sheet per overtone, with columns ell, hat_n, Q, omega_re, omega_im. Additional roots without an assigned parent among these families are excluded.

MATLAB: `plot_RN` (all), `plot_RN(2,8)` (one family).
Mathematica: load `plot_RN.wl`, then `RNPlot[]` or `RNPlot[2,8]`.
Python: `python plot_RN.py` or `python plot_RN.py --ell 2 --n 8`.

Paper: [arXiv:2611.24647](https://arxiv.org/abs/2611.24647).

```bibtex
@article{Chen:2026swp,
    author = "Chen, Changkai and Zhang, Xiaohua and Cao, Zhoujian and Jing, Jiliang",
    title = {{Complete quasinormal modes of Type-D black holes. III. Reissner-Nordstr{\"o}m spectra from zero to extremal charge}},
    eprint = "2611.24647",
    archivePrefix = "arXiv",
    primaryClass = "gr-qc",
    month = "11",
    year = "2026"
}
```
