# The Influence of IQ on the Brain’s Auditory Cortex Activation in Schizophrenia

Created by:
Rheka Narwastu, Paige Pagaduan, Katrina Suherman

This repository contains a reproducible neuroimaging analysis pipeline investigating **how individual differences in intelligence quotient (IQ) relate to auditory cortex activation in individuals with schizophrenia**. The analysis is performed using FSL FEAT group-level fMRI modeling and includes covariate control for age and sex.

The study compares three participant groups:

- **AVH+**: schizophrenia patients experiencing auditory verbal hallucinations  
- **AVH−**: schizophrenia patients without recent auditory hallucinations  
- **HC**: healthy control participants  


## Analysis Overview

This pipeline investigates how individual differences in IQ relate to auditory cortex activation in schizophrenia using fMRI data processed with FSL.

The analysis consists of the following steps:

1. **Download the dataset**
   The fMRI dataset is downloaded from OpenNeuro and organized locally for analysis.

2. **Preprocessing and first level analysis**
   Each subject’s functional MRI data are preprocessed and modeled using FSL FEAT to generate subject level statistical maps.

3. **Second level analysis (group level)**
   Statistical modeling is performed to compare activation patterns across participant groups (AVH+, AVH−, and HC).

4. **ROI analysis**
   Mean activation values are extracted from the selected auditory cortex region of interest using the subject level contrast images.

5. **Visualization of IQ–activation relationships**
   Activation values from the region of interest are combined with behavioral data to visualize and analyze the relationship between IQ and neural activation.

All analyses are performed in standard MNI space.

## Repository Layout

#### `first_level/`

* `fsf_first_level.fsf` — template FSL FEAT design for preprocessing and first level analysis
* `run_1stLevel_Analysis.sh` — script to run preprocessing and first level analysis for each subject

---

#### `second_level/`

* `design_run_HC_01_25.fsf` — FEAT design for Healthy Controls group analysis (sub-01 to sub-25)
* `design_run_AVH-_26_54.fsf` — FEAT design for AVH− group analysis (sub-26 to sub-54)
* `design_run_AVH+_55_77.fsf` — FEAT design for AVH+ group analysis (sub-55 to sub-77)
* `run_2ndLevel_Analysis_HC_01_25.sh` — script to run group level FEAT for Healthy Controls
* `run_2ndLevel_Analysis_AVH-_26_54.sh` — script to run group level FEAT for AVH−
* `run_2ndLevel_Analysis_AVH+_55_77.sh` — script to run group level FEAT for AVH+

---

#### `ROI_analysis/`

* `run_roi_all.sh` — script to extract ROI mean activation values for all subjects
* `masks/` — ROI mask files used for extraction

  * `auditory_cortex.nii.gz` — auditory cortex ROI mask
  * `right_crus_I.nii.gz` — right crus I gyrus ROI mask

---

#### `timing_files/`

* `task_sentences_events.txt` — timing file for sentences condition
* `task_words_events.txt` — timing file for words condition
* `task_reversed_events.txt` — timing file for reversed speech condition
* `task_white-noise_events.txt` — timing file for white noise condition

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

#### 3. Run FSL in terminal:
```
fsl
```

If you are using Linux or Windows, refer to the official website: 
https://fsl.fmrib.ox.ac.uk/fsl/docs/install/index.html

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

**IF YOU ARE CLONING THE DATA FROM THE GIT REPOSITORY ON OPENNEURO:**

1. Install DataLad on your device.
2. Navigate to the cloned dataset and run:

```bash
datalad get .
```

This step pulls the actual anatomical data from the Github repository for use in the following analyses. Otherwise, the script will not be able to accurately locate the anatomical data and produce an error.

---

### 2. Copy project files into the dataset folder

Clone or download this repository, then copy the following folders into your dataset directory:

```
timing_files/
first_level/
second_level/
ROI_analysis/
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
└── ROI_analysis/
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

## Preparing Data for Second Level Analysis

Before running group level FEAT, each subject first level output must include a `reg_standard/` directory inside their `.feat` folder.

### Why this step is necessary

First level FEAT writes registration results to `reg/`. Group level FEAT expects standard space versions of key files (including a mask) in `reg_standard/` so it can build a common analysis space across subjects.

If `reg_standard/` or `reg_standard/mask` is missing, group level FEAT can fail during input preparation.

The command `featregapply` generates `reg_standard/` using the existing registration from the first level analysis, so it is safe to run after first level has completed.

---

## Generate reg_standard for all subjects (sub-01 to sub-77)

Run this from the dataset root directory:

```bash
for d in sub-*/func/sub-*_task-speech_bold.feat; do
  subj=$(basename "$d" | cut -d'_' -f1)

  if [ ! -f "$d/reg_standard/mask" ] && [ ! -f "$d/reg_standard/mask.nii.gz" ]; then
    echo "Creating reg_standard for ${subj}"
    "$FSLDIR/bin/featregapply" "$d"
  else
    echo "reg_standard already exists for ${subj}"
  fi
done
````

---

## Verify outputs

Check one subject:

```bash
ls sub-01/func/sub-01_task-speech_bold.feat/reg_standard
```

You should see files such as:

```text
example_func.nii.gz
mean_func.nii.gz
stats
mask.nii.gz
reg
```

Once subjects include `reg_standard/`, you are ready to run second level analysis.

---

## Second Level Analysis

Before running this step, make sure to copy the **second_level** folder from this repository into your dataset directory.

This folder contains:

* All second level FEAT design files (`.fsf`)
* All scripts required to run the group level analyses

Your directory should look like:

```
your_data_folder/
├── sub-01/
├── sub-02/
├── ...
├── timing_files/
├── first_level/
├── second_level/
│   ├── design_run_HC_01_25.fsf
│   ├── design_run_AVH-_26_54.fsf
│   ├── design_run_AVH+_55_77.fsf
│   ├── run_2ndLevel_Analysis_HC_01_25.sh
│   ├── run_2ndLevel_Analysis_AVH-_26_54.sh
│   └── run_2ndLevel_Analysis_AVH+_55_77.sh
```

After `reg_standard/` has been created for all subjects, you can run the group level FEAT analyses for each cohort.

---

### 1. Healthy Controls

Run from the dataset root:

```bash
bash second_level/run_2ndLevel_Analysis_HC_01_25.sh
```

Output:

```
second_level_output/hc.gfeat
```

---

### 2. AVH-

Run from the dataset root:

```bash
bash second_level/run_2ndLevel_Analysis_AVH-_26_54.sh
```

Output:

```
second_level_output/avh-.gfeat
```

---

### 3. AVH+

Run from the dataset root:

```bash
bash second_level/run_2ndLevel_Analysis_AVH+_55_77.sh
```

Output:

```
second_level_output/avh+.gfeat
```


## Output

After running all three group analyses, the results will be located in:

```
second_level_output/
```

The directory should contain:

```
second_level_output/
├── hc.gfeat
├── avh-.gfeat
└── avh+.gfeat
```

Each `.gfeat` directory contains the group level statistical maps, cluster results, and FEAT reports for that cohort.


Here is a section you can **paste directly into your README** under the Second Level Analysis section. It matches your style and structure.

---

## ROI Analysis

ROI analysis extracts mean activation values from predefined brain regions and evaluates the relationship between activation and IQ.

In this project, ROI analysis is performed for:

* Right Crus I
* Auditory cortex

The script extracts subject level activation from selected contrasts, merges the values with participant data, and generates scatter plots with regression lines.

---

## Preparing ROI Analysis

Before running this step:

1. Make sure first level analysis has completed for all subjects.
2. Ensure that each subject contains:

```
sub-XX/func/sub-XX_task-speech_bold.feat/reg_standard/stats/
```

which should include files such as:

```
cope1.nii.gz
cope3.nii.gz
cope5.nii.gz
```

---


## Copy the ROI_analysis folder

Download or copy the folder from this repository:

```
ROI_analysis/
```

into your dataset root directory.

After copying, your structure should look like:

```
your_data_folder/
├── sub-01/
├── sub-02/
├── ...
├── timing_files/
├── first_level/
├── second_level/
└── ROI_analysis/
    ├── masks/
    │   ├── right_crus_I.nii.gz
    │   └── auditory_cortex.nii.gz
    └── run_roi_all.sh
```

Make sure all files inside `ROI_analysis/` are copied, especially the `masks/` directory and the script.


## Running ROI Analysis

From the dataset root directory, run:

```bash
bash ROI_analysis/run_roi_all.sh
```

The script will:

1. Extract mean activation values from each ROI
2. Merge activation values with participant information
3. Compute regression statistics
4. Generate plots for each contrast and ROI

---

## Output Structure

After running the script, results will be saved in:

```
ROI_analysis_output/
```

Example structure:

```
ROI_analysis_output/
├── right_crus_I/
│   ├── files/
│   │   ├── roi_activation_right_crus_I_sentences.csv
│   │   ├── roi_activation_right_crus_I_words.csv
│   │   ├── roi_activation_right_crus_I_reversed.csv
│   │   ├── merged_right_crus_I_sentences.csv
│   │   ├── merged_right_crus_I_words.csv
│   │   └── merged_right_crus_I_reversed.csv
│   └── plots/
│       ├── iq_vs_right_crus_I_sentences.png
│       ├── iq_vs_right_crus_I_words.png
│       └── iq_vs_right_crus_I_reversed.png
│
└── auditory_cortex/
    ├── files/
    ├── plots/
```

---

## Explanation of Outputs

### Activation files

Files named:

```
roi_activation_<region>_<contrast>.csv
```

contain:

* participant ID
* mean ROI activation value

These values are extracted using:

```
fslmeants
```

from the subject level contrast maps.

---

### Merged files

Files named:

```
merged_<region>_<contrast>.csv
```

contain:

* participant ID
* group (HC, AVH+, AVH−)
* IQ score
* ROI activation

These files are used for statistical analysis and plotting.

---

### Plots

Each plot shows:

* IQ vs activation
* Separate regression lines per group
* Confidence intervals
* Correlation statistics

Example:

```
iq_vs_right_crus_I_sentences.png
```

These figures are suitable for inclusion in reports and presentations.

---

## Citation

> Soler-Vidal, J., et al. (2022). *Brain correlates of speech perception in schizophrenia patients with and without auditory hallucinations*. **PLOS ONE**.

---
