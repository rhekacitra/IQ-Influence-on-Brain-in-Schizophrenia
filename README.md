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

---

## Downloading the Dataset

The fMRI dataset used in this project is publicly available on OpenNeuro.

Download it from:
[https://openneuro.org/datasets/ds004302/versions/1.0.0/download](https://openneuro.org/datasets/ds004302/versions/1.0.0/download)

### 1. Download using your browser

1. Open the link above in your web browser.
2. Navigate to **Download with your browser** and click **Download**.
3. Choose or create a folder where the dataset will be saved.

After downloading and extracting, your structure should look like:

```
your_data_folder/
├── sub-01/
├── sub-02/
├── sub-03/
└── ...
```

---

### 2. Copy project files into the dataset folder

Clone or download this repository, then copy the following folders into your dataset directory:

```
timing_files/
first_level/
second_level/
roi_activation/
```

After copying, the structure should look like:

```
your_data_folder/
├── sub-01/
├── sub-02/
├── sub-03/
├── timing_files/
├── first_level/
├── second_level/
└── roi_activation/
```

The dataset folder will now serve as the working directory for all analyses.

### Notes

* The dataset is large, so the download may take some time depending on your internet speed.
* Make sure the subject folder names remain in the format `sub-XX`, as the analysis scripts rely on this structure.

---

## First Level Analysis

### 1. Prepare timing files

First level modeling in FSL requires timing files that define when each stimulus condition occurred. These timing files are provided in this repository and should already be located in:

```
timing_files/
```

At this stage, your dataset directory should look like:

```
your_data_folder/
├── sub-01/
├── sub-02/
├── sub-03/
├── ...
├── timing_files/
├── first_level/
├── second_level/
└── roi_activation/
```

---

### 2. Copy timing files into each subject folder

FSL expects timing files to be located inside each subject’s functional directory:

```
sub-01/func/
sub-02/func/
...
```

Run the following script from the dataset directory:

```bash
TIMING_ROOT="timing_files"

for subj_dir in sub-*; do
  func_dir="${subj_dir}/func"

  mkdir -p "$func_dir"
  cp "${TIMING_ROOT}/"*.txt "$func_dir/"

  echo "Copied timing files -> $func_dir"
done
```

---

### 3. Verify timing files

Check one subject:

```bash
ls sub-01/func
```

You should see files such as:

```
sub-01_task-speech_bold.nii.gz
task_words_events.txt
task_sentences_events.txt
task_white-noise_events.txt
task_reversed_events.txt
```

These timing files are now ready to be used in the first level FEAT design.

---

## Preprocessing and First Level Analysis

Before running this step, make sure the following files are present inside the dataset directory:

```
first_level/
├── fsf_first_level.fsf
└── run_1stLevel_Analysis.sh
```

These files define the FEAT design and the script used to run preprocessing and first level modeling for each subject.

### Run preprocessing and first level analysis

From the dataset root directory, run:

```bash
bash first_level/run_1stLevel_Analysis.sh
```

The script will:

* Check that required files exist for each subject
* Generate a subject specific FEAT design file
* Run FEAT preprocessing and first level GLM analysis
* Save outputs inside each subject’s `func/` directory

Example output location:

```
sub-01/func/sub-01_task-speech_bold.feat
```

### Viewing results

After FEAT finishes for a subject, an HTML report is automatically generated.
This report contains:

* Preprocessing summaries
* Registration results
* Model fit diagnostics
* Statistical maps and thresholded images
* Log files

You can open the report in a browser by navigating to the `.feat` folder and opening:

```
report.html
```

For example:

```
sub-01/func/sub-01_task-speech_bold.feat/report.html
```

### Output files for analysis

Inside the `.feat` directory, important statistical outputs can be found in:

```
stats/
```

Common files include:

* `cope*.nii.gz` — contrast parameter estimates
* `zstat*.nii.gz` — z statistic maps
* `pe*.nii.gz` — parameter estimates for each regressor

These files are used in ROI analysis and higher level modeling.

### Runtime

This step is computationally intensive.
Running preprocessing and first level analysis for all subjects typically takes **approximately 6 to 7 hours**, depending on CPU speed and system load.

It is recommended to run this step on a machine that can remain active for several hours.

## Citation

> Soler-Vidal, J., et al. (2022). *Brain correlates of speech perception in schizophrenia patients with and without auditory hallucinations*. **PLOS ONE**.

---
