#!/bin/bash
set -euo pipefail

# Run from dataset root: your_data_folder
ROOT_DIR="$(pwd)"

TEMPLATE_FSF="${ROOT_DIR}/first_level/fsf_first_level.fsf"
if [ ! -f "${TEMPLATE_FSF}" ]; then
  echo "ERROR: Cannot find template FSF at: ${TEMPLATE_FSF}"
  echo "Put fsf_first_level.fsf in the first_level and try again."
  exit 1
fi

# Edit this list
SUBJECTS="$(ls -d sub-* 2>/dev/null | sort || true)"

if [ -z "${SUBJECTS}" ]; then
  echo "ERROR: No subject IDs provided."
  exit 1
fi

echo "Found subjects:"
echo "${SUBJECTS}"
echo

for subj in ${SUBJECTS}; do
  echo "===> Starting processing of ${subj}"
  echo

  SUBJ_DIR="${ROOT_DIR}/${subj}"
  ANAT_DIR="${SUBJ_DIR}/anat"
  FUNC_DIR="${SUBJ_DIR}/func"

  if [ ! -d "${ANAT_DIR}" ]; then
    echo "WARNING: Missing anat directory for ${subj}, skipping."
    echo
    continue
  fi
  if [ ! -d "${FUNC_DIR}" ]; then
    echo "WARNING: Missing func directory for ${subj}, skipping."
    echo
    continue
  fi

  # Structural image you want FEAT to use
  STRUCT_IMG="${ANAT_DIR}/${subj}_T1w.nii.gz"
  if [ ! -f "${STRUCT_IMG}" ]; then
    echo "WARNING: Missing structural image ${STRUCT_IMG}, skipping ${subj}."
    echo
    continue
  fi

  # Structural path without extension (FSF often stores this without .nii.gz)
  STRUCT_BASE="${ANAT_DIR}/${subj}_T1w"

  # Functional file
  BOLD="${FUNC_DIR}/${subj}_task-speech_bold.nii.gz"
  if [ ! -f "${BOLD}" ]; then
    echo "WARNING: Missing functional file ${BOLD}, skipping ${subj}."
    echo
    continue
  fi

  # Timing files
  EV1="${FUNC_DIR}/task_white-noise_events.txt"
  EV2="${FUNC_DIR}/task_sentences_events.txt"
  EV3="${FUNC_DIR}/task_words_events.txt"
  EV4="${FUNC_DIR}/task_reversed_events.txt"

  missing_ev=0
  for ev in "${EV1}" "${EV2}" "${EV3}" "${EV4}"; do
    if [ ! -f "${ev}" ]; then
      echo "WARNING: Missing timing file: ${ev}"
      missing_ev=1
    fi
  done
  if [ "${missing_ev}" -eq 1 ]; then
    echo "Skipping ${subj} due to missing timing file(s)."
    echo
    continue
  fi

  # Copy template FSF into subject dir
  cd "${SUBJ_DIR}"
  cp "${TEMPLATE_FSF}" ./design_run1.fsf

  # Replace subject id occurrences (template must contain SUBJECT_ID placeholder)
  sed -i '' "s|SUBJECT_ID|${subj}|g" design_run1.fsf

  # Force structural paths in the FSF
  if grep -q 'set fmri(structural)' design_run1.fsf; then
    sed -i '' \
      "s|set fmri(structural).*|set fmri(structural) \"${STRUCT_IMG}\"|g" \
      design_run1.fsf
  else
    echo "set fmri(structural) \"${STRUCT_IMG}\"" >> design_run1.fsf
  fi

  # Also force highres_files(1) if present (often used by FEAT registration)
  if grep -q 'set highres_files(1)' design_run1.fsf; then
    sed -i '' \
      "s|set highres_files(1).*|set highres_files(1) \"${STRUCT_BASE}\"|g" \
      design_run1.fsf
  fi

  echo "Structural set to:"
  grep -n 'fmri(structural)\|highres_files(1)' design_run1.fsf || true
  echo

  echo "===> Running feat for ${subj}"
  feat design_run1.fsf
  echo

  cd "${ROOT_DIR}"
done

echo "All done."
