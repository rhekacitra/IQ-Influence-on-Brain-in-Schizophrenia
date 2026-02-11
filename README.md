# The Influence of IQ on the Brain’s Auditory Cortex Activation in Schizophrenia

Created by:

- Rheka Narwastu:
- Paige Pagaduan:
- Katrina Suherman:

This repository contains a reproducible neuroimaging analysis pipeline investigating **how individual differences in intelligence quotient (IQ) relate to auditory cortex activation in individuals with schizophrenia**. The analysis is performed using FSL FEAT group-level fMRI modeling and includes covariate control for age and sex.

The study compares three participant groups:

- **AVH+**: schizophrenia patients experiencing auditory verbal hallucinations  
- **AVH−**: schizophrenia patients without recent auditory hallucinations  
- **HC**: healthy control participants  


## Analysis overview

The pipeline performs:

1. **Preprocessing** preparation of functional MRI data for statistical analysis  
2. **First-level analysis** subject-level GLM modeling
3. **Group-level GLM modeling** using FSL FEAT  
4. **Covariate modeling** of IQ, age, and sex within the group analysis  
5. **Extraction of peak activation coordinates** from significant clusters  
6. **Anatomical labeling** of activation peaks using brain atlases  
7. **Generation of reproducible tables and figures** for reporting results  

All analyses are performed in standard MNI space.

## Repository Layout
#### `preprocessing/`

---

#### `first_level/`

- `first_level_design.fsf` — template FSL FEAT design for first-level analysis
---

#### `second_level/`

- `avh_plus_design.fsf` — FEAT design modeling AVH+ participants  
- `avh_minus_design.fsf` — FEAT design modeling AVH− participants  
- `healthy_design.fsf` — FEAT design modeling healthy controls  


---

#### `roi_activation/`


---

#### `results/`

- `figures/` — thresholded brain maps and visualization outputs  

---

## Requirements

- FSL (FEAT, FSLEyes, atlasquery)
- Bash shell
- Python for generating plots

Installation instructions are provided below.

### macOS Installation (Step-by-step)


#### 1. Download the FSL installer

Open Terminal and run:

```
curl -Ls https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/getfsl.sh | sh -s
```

#### 2. Verify installation:
```
fslversion
```
```
atlasquery --help
```


#### 3. Run FSL in terminal:
```
fsl
```

If you are using Linux or Windows, refer to the official website: 
https://fsl.fmrib.ox.ac.uk/fsl/docs/install/index.html

---

### Run with Docker

## Citation

> Soler-Vidal, J., et al. (2022). *Brain correlates of speech perception in schizophrenia patients with and without auditory hallucinations*. **PLOS ONE**.

---
