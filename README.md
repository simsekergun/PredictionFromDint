# PredictionFromDint
Predicting ring dimensions and Sellmeier model from integrated dispersion datasets.


We consider a microring resonator composed of Si$_3$N$_4$ as the core material and SiO$_2$ as the cladding. The outer ring radius is fixed at $23~\mu$m, while the waveguide height and width are varied to construct a comprehensive dataset for dispersion analysis. Specifically, the height is swept from $620$~nm to $720$~nm in increments of $5$~nm, and the width is swept from $750$~nm to $950$~nm in increments of $10$~nm, resulting in $441$ unique training designs. In addition, we generate a test dataset by randomly selecting $50$ distinct integer width–height combinations (in nanometers) from the same ranges as the training dataset.


To accurately capture material dispersion, we employ wavelength-dependent relative permittivity models for both Si$_3$N$_4$ and SiO$_2$.



@article{Moille:21,
author = {Gregory Moille and Daron Westly and Gregory Simelgor and Kartik Srinivasan},
journal = {Opt. Lett.},
keywords = {Chemical vapor deposition; Frequency combs; Nonlinear absorption; Refractive index; Ring resonators; Silicon nitride},
number = {23},
pages = {5970--5973},
publisher = {Optica Publishing Group},
title = {Impact of the precursor gas ratio on dispersion engineering of broadband silicon nitride microresonator frequency combs},
volume = {46},
month = {Dec},
year = {2021},
url = {https://opg.optica.org/ol/abstract.cfm?URI=ol-46-23-5970},
doi = {10.1364/OL.440907},
abstract = {Microresonator frequency combs, or microcombs, have gained wide appeal for their rich nonlinear physics and wide range of applications. Stoichiometric silicon nitride films grown via low-pressure chemical vapor deposition (LPCVD), in particular, are widely used in chip-integrated Kerr microcombs. Critical to such devices is the ability to control the microresonator dispersion, which has contributions from both material refractive index dispersion and geometric confinement. Here, we show that modifications to the ratio of the gaseous precursors in LPCVD growth have a significant impact on material dispersion and hence the overall microresonator dispersion. In contrast to the many efforts focused on comparisons between Si-rich films and stoichiometric (Si3N4) films, here, we focus on films whose precursor gas ratios should nominally place them in the stoichiometric regime. We further show that microresonator geometric dispersion can be tuned to compensate for changes in the material dispersion.},
}



% SiO2 Sellmeier
@article{TAN1998158,
title = {Determination of refractive index of silica glass for infrared wavelengths by IR spectroscopy},
journal = {Journal of Non-Crystalline Solids},
volume = {223},
number = {1},
pages = {158-163},
year = {1998},
issn = {0022-3093},
doi = {https://doi.org/10.1016/S0022-3093(97)00438-9},
url = {https://www.sciencedirect.com/science/article/pii/S0022309397004389},
author = {C.Z. Tan},
abstract = {An interferometric method was used to determine the refractive index of silica glass in the infrared wavelength range by means of IR spectroscopy. The wavelength-dependent refractive indices were measured for wavelengths ranging from 3 to 6.7 μm. The refractive index in the investigated wavelength region can be well described with a three-term Sellmeier equation.}
}

