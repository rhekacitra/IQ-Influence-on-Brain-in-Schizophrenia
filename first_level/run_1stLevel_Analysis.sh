#!/bin/bash
set -euo pipefail

# Run from dataset root: your_data_folder
ROOT_DIR="$(pwd)"

TEMPLATE_FSF="${ROOT_DIR}/first_level/fsf_first_level.fsf"
if [ ! -f "${TEMPLATE_FSF}" ]; then
  echo "ERROR: Cannot find template FSF at: ${TEMPLATE_FSF}"
  echo "Put fsf_first_level.fsf in first_level/ and try again."
  exit 1
fi

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

  STRUCT_IMG="${ANAT_DIR}/${subj}_T1w.nii.gz"
  if [ ! -f "${STRUCT_IMG}" ]; then
    echo "WARNING: Missing structural image ${STRUCT_IMG}, skipping ${subj}."
    echo
    continue
  fi
  STRUCT_BASE="${ANAT_DIR}/${subj}_T1w"

  BOLD="${FUNC_DIR}/${subj}_task-speech_bold.nii.gz"
  if [ ! -f "${BOLD}" ]; then
    echo "WARNING: Missing functional file ${BOLD}, skipping ${subj}."
    echo
    continue
  fi
  BOLD_BASE="${FUNC_DIR}/${subj}_task-speech_bold"

  EV_SENT="${FUNC_DIR}/task_sentences_events.txt"
  EV_WORD="${FUNC_DIR}/task_words_events.txt"
  EV_REV="${FUNC_DIR}/task_reversed_events.txt"
  EV_WN="${FUNC_DIR}/task_white-noise_events.txt"  # only used if FSF has custom4

  missing_ev=0
  for ev in "${EV_SENT}" "${EV_WORD}" "${EV_REV}"; do
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

  cd "${SUBJ_DIR}"
  cp "${TEMPLATE_FSF}" ./design_run1.fsf

  # Replace placeholder if present
  sed -i '' "s|SUBJECT_ID|${subj}|g" design_run1.fsf

  # Force outputdir to be subject-local and deterministic
  # FEAT interprets relative paths relative to where you run feat (SUBJ_DIR here)
  OUTDIR_REL="func/${subj}_task-speech_bold.feat"
  if grep -q '^set fmri(outputdir)' design_run1.fsf; then
    sed -i '' "s|^set fmri(outputdir).*|set fmri(outputdir) \"${OUTDIR_REL}\"|g" design_run1.fsf
  else
    echo "set fmri(outputdir) \"${OUTDIR_REL}\"" >> design_run1.fsf
  fi

  # Force structural paths
  if grep -q '^set fmri(structural)' design_run1.fsf; then
    sed -i '' "s|^set fmri(structural).*|set fmri(structural) \"${STRUCT_IMG}\"|g" design_run1.fsf
  else
    echo "set fmri(structural) \"${STRUCT_IMG}\"" >> design_run1.fsf
  fi
  if grep -q '^set highres_files(1)' design_run1.fsf; then
    sed -i '' "s|^set highres_files(1).*|set highres_files(1) \"${STRUCT_BASE}\"|g" design_run1.fsf
  fi

  # Force functional input
  if grep -q '^set feat_files(1)' design_run1.fsf; then
    sed -i '' "s|^set feat_files(1).*|set feat_files(1) \"${BOLD_BASE}\"|g" design_run1.fsf
  else
    echo "set feat_files(1) \"${BOLD_BASE}\"" >> design_run1.fsf
  fi

  # Force EV timing files (3-EV setup)
  if grep -q '^set fmri(custom1)' design_run1.fsf; then
    sed -i '' "s|^set fmri(custom1).*|set fmri(custom1) \"${EV_SENT}\"|g" design_run1.fsf
  fi
  if grep -q '^set fmri(custom2)' design_run1.fsf; then
    sed -i '' "s|^set fmri(custom2).*|set fmri(custom2) \"${EV_WORD}\"|g" design_run1.fsf
  fi
  if grep -q '^set fmri(custom3)' design_run1.fsf; then
    sed -i '' "s|^set fmri(custom3).*|set fmri(custom3) \"${EV_REV}\"|g" design_run1.fsf
  fi

  # Optional custom4
  if grep -q '^set fmri(custom4)' design_run1.fsf; then
    if [ -f "${EV_WN}" ]; then
      sed -i '' "s|^set fmri(custom4).*|set fmri(custom4) \"${EV_WN}\"|g" design_run1.fsf
    fi
  fi

  # Safety check: fail only if FSF contains some OTHER subject id
  # This catches the original bug (sub-15 FSF still pointing to sub-01)
  other_subj_lines="$(grep -nE 'sub-[0-9]{2}' design_run1.fsf | grep -v "${subj}" || true)"
  if [ -n "${other_subj_lines}" ]; then
    echo "ERROR: design_run1.fsf contains paths for a different subject. Not running FEAT for ${subj}."
    echo "${other_subj_lines}"
    cd "${ROOT_DIR}"
    exit 1
  fi

  echo "Key FSF paths for ${subj}:"
  grep -n '^set fmri(outputdir)\|^set feat_files(1)\|^set fmri(structural)\|^set highres_files(1)\|^set fmri(custom[1-4])' design_run1.fsf || true
  echo

  echo "===> Running feat for ${subj}"
  feat design_run1.fsf
  echo

  cd "${ROOT_DIR}"
done

echo "All done."
