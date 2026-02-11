#!/bin/bash
set -euo pipefail

# Run from dataset root: ds004302-download
ROOT_DIR="$(pwd)"

TEMPLATE_FSF="${ROOT_DIR}/design_run1.fsf"
if [ ! -f "${TEMPLATE_FSF}" ]; then
  echo "ERROR: Cannot find template FSF at: ${TEMPLATE_FSF}"
  echo "Put design_run1.fsf in the dataset root and try again."
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

  # Functional file (adjust if name differs)
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

  # Replace subject id occurrences (template must contain sub-01 somewhere)
  sed -i '' "s|sub-01|${subj}|g" design_run1.fsf

  # Optional: replace root path if your template has hardcoded absolute root
  # TEMPLATE_ROOT="/Users/katy/Desktop/ds004302-download"
  # sed -i '' "s|${TEMPLATE_ROOT}|${ROOT_DIR}|g" design_run1.fsf

  # Force the main structural image path in the FSF
  if grep -q 'set fmri(structural)' design_run1.fsf; then
    sed -i '' \
      "s|set fmri(structural).*|set fmri(structural) \"${STRUCT_IMG}\"|g" \
      design_run1.fsf
  else
    # If your template FSF did not contain this line, append it
    echo "set fmri(structural) \"${STRUCT_IMG}\"" >> design_run1.fsf
  fi

  echo "Structural set to:"
  grep 'fmri(structural)' design_run1.fsf || true
  echo

  echo "===> Running feat for ${subj}"
  feat design_run1.fsf
  echo

  cd "${ROOT_DIR}"
done

echo "All done."
