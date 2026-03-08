# The Influence of IQ on the Brain’s Auditory Cortex Activation in Schizophrenia

Created by:
Rheka Narwastu, Paige Pagaduan, Katrina Suherman

This repository contains a reproducible neuroimaging analysis pipeline investigating **how individual differences in intelligence quotient (IQ) relate to auditory cortex activation in individuals with schizophrenia**.

Example outputs from the analysis pipeline are included in this repository within the folders `second_level_output/` and `ROI_analysis_output/`, demonstrating the expected structure of generated results.

## Introduction

Schizophrenia is a chronic psychiatric disorder that affects approximately 1% of the global population and is often associated with difficulties in speech perception. These difficulties have been linked to altered activation in the auditory cortex, a brain region responsible for processing auditory information. In addition to auditory regions, higher cognitive processing has also been associated with cerebellar regions such as right Crus I.

Previous neuroimaging studies investigating speech perception in schizophrenia have frequently focused on symptom groups, particularly the presence or absence of auditory verbal hallucinations (AVH). However, hallucination status alone may not fully explain variability in speech related brain responses. Differences in cognitive ability, such as intelligence quotient (IQ), may also contribute to variation in neural activation during speech processing.

This project investigates whether individual differences in IQ are associated with brain activation during speech perception. Using an openly available functional magnetic resonance imaging (fMRI) dataset from OpenNeuro, we analyze neural responses to spoken words, spoken sentences, and reversed speech in three participant groups: healthy controls (HC), schizophrenia patients without hallucinations (AVH−), and schizophrenia patients with hallucinations (AVH+).

The analysis focuses on two regions of interest:

- **Auditory cortex**, which processes speech sounds  
- **Right Crus I**, a cerebellar region linked to higher cognitive processing

The goal of this study is to examine whether variability in speech related brain activation may be associated with differences in cognitive ability rather than hallucination status alone.


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

#### `second_level_output/`

Contains the group level FEAT results generated from the second level analysis.  
Each `.gfeat` directory includes statistical maps, cluster reports, and FEAT summary files.

---

#### `ROI_analysis_output/`

Contains outputs generated during ROI analysis, including extracted activation values and plots showing the relationship between IQ and brain activation.

This folder includes:

- CSV files containing ROI activation values
- Merged datasets combining activation and participant information
- Generated figures visualizing IQ–activation relationships

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

The analysis is divided into two stages:
- ROI extraction and data merging (performed using FSL and Bash)
- Plot generation (performed using Python inside a Docker container)

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

After copying, your directory should look like:

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
    ├── plot_roi.py
    └── run_roi_all.sh
```

Make sure all files inside `ROI_analysis/` are copied, especially the `masks/` directory and both scripts.

---
## Part 1: Extract ROI Values and Merge with Participant Data

Run the ROI extraction and merging step using:

```
bash ROI_analysis/run_roi_all.sh
```

The script will:

1. Extract mean activation values from each ROI
2. Save ROI activation values for each subject
3. Merge activation values with participant information
4. Impute missing IQ values with the dataset mean (IQ = 100) within `run_roi_all.sh` before merging, allowing all participants to be included in the IQ–activation analysis.

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
│   └── files/
│       ├── roi_activation_right_crus_I_sentences.csv
│       ├── roi_activation_right_crus_I_words.csv
│       ├── roi_activation_right_crus_I_reversed.csv
│       ├── merged_right_crus_I_sentences.csv
│       ├── merged_right_crus_I_words.csv
│       └── merged_right_crus_I_reversed.csv

│
└── auditory_cortex/
    └── files/
        ├── roi_activation_auditory_cortex_sentences.csv
        ├── roi_activation_auditory_cortex_words.csv
        ├── roi_activation_auditory_cortex_reversed.csv
        ├── merged_auditory_cortex_sentences.csv
        ├── merged_auditory_cortex_words.csv
        └── merged_auditory_cortex_reversed.csv
```

---
## Part 2: Generate Plots Using Docker
The plotting step uses Python and is containerized using Docker to ensure reproducibility across different systems.

Before running the Docker container, make sure the following files from this repository are present in your dataset root directory:

```
Dockerfile
requirements.txt
.dockerignore
```
You can obtain these files by either cloning or manually copying the files.

By cloning the repository:
```
git clone https://github.com/rhekacitra/IQ-Influence-on-Brain-Auditory-Cortex-in-Schizophrenia.git
```
Then copy the required files into your dataset directory:
```
Dockerfile
requirements.txt
.dockerignore
```
Build the Docker Image:

```
docker build -t fmri-roi-plotter .
```
This command builds a Docker image that contains:

- Python
- required Python libraries
- the plotting script

Run the Docker Container:
```
docker run --rm -v "$(pwd)":/app fmri-roi-plotter
```
This command:
- mounts the current dataset directory inside the container
- runs the plotting script
- saves the generated figures back to your local directory

---
## Output Structure
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
    └── plots/
```
## Explanation of Outputs

### ROI Activation Files

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

from the subject-level contrast maps.

---

### Merged Data Files

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

## Discussion

Second level analysis shows that both schizophrenia groups (AVH+ and AVH−) exhibit strong activation in the auditory cortex during speech perception, with similar spatial activation patterns across groups.

ROI analysis found no significant relationship between IQ and auditory cortex activation. However, significant associations were observed in the cerebellar region right Crus I during the Words contrast. Higher IQ was associated with lower activation in the AVH+ group and higher activation in the AVH− group.

These findings suggest that cerebellar regions such as right Crus I may reflect individual differences in the cognitive processing of speech.

## Limitations and Future Work

This analysis is limited by the available dataset, which includes only a small set of participant variables (age, sex, IQ, and diagnostic group). Additional demographic or clinical variables could help account for potential confounding factors affecting brain activation.

Future work could include larger participant samples to improve statistical power and better assess group level trends. Incorporating additional cognitive assessments may also allow investigation of brain regions involved in broader cognitive processes beyond auditory and language related functions.

## Conclusion

This study examined the relationship between IQ and brain activation during speech perception across healthy controls and schizophrenia groups. Auditory cortex activation was consistent across groups, with no significant association between IQ and auditory cortex activity.

However, significant IQ related effects were observed in the cerebellar region right Crus I during the Words contrast in both schizophrenia groups, with opposite directions of association. These findings suggest that cerebellar regions may reflect individual differences in the cognitive processing of speech.

## Evaluation and Reproducibility

Evaluation metrics include linear regression coefficients, Pearson correlation values, and p values derived from ROI activation analyses. Group level statistical maps are generated using FSL FEAT.

All intermediate and final outputs are saved within `second_level_output/` and `ROI_analysis_output/`. The analysis pipeline can be reproduced by running the provided bash scripts for first level analysis, group level analysis, and ROI extraction.

FSL automatically generates log files and HTML reports for each FEAT run, providing model diagnostics and statistical summaries for verification and reproducibility.

Formal unit tests are not included, as this repository represents a neuroimaging analysis pipeline rather than a software library.

---
## Citation

> Soler-Vidal, J., et al. (2022). *Brain correlates of speech perception in schizophrenia patients with and without auditory hallucinations*. **PLOS ONE**.

---
