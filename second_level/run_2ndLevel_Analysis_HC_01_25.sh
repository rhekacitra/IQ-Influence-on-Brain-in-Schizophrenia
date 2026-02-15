#!/bin/bash
set -euo pipefail

ROOT_DIR="$(pwd)"

BASE_FSF="${ROOT_DIR}/second_level/design_run_HC_01_25.fsf"
if [ ! -f "${BASE_FSF}" ]; then
  echo "ERROR: Cannot find base FSF at: ${BASE_FSF}"
  exit 1
fi

TMP_FSF="$(mktemp "${ROOT_DIR}/second_level/tmp_design_HC_01_25_XXXXXX.fsf")"
cp "${BASE_FSF}" "${TMP_FSF}"

# Force output directory
OUTPUT_DIR="${ROOT_DIR}/second_level_output/hc.gfeat"
mkdir -p "${ROOT_DIR}/second_level_output"

sed -i '' "s|^set fmri(outputdir).*|set fmri(outputdir) \"${OUTPUT_DIR}\"|g" "${TMP_FSF}"

# Build inputs sub-01..sub-25
feat_dirs=()
for i in $(seq -w 1 25); do
  d="${ROOT_DIR}/sub-${i}/func/sub-${i}_task-speech_bold.feat"
  if [ ! -d "${d}" ]; then
    echo "ERROR: Missing first level FEAT dir: ${d}"
    rm -f "${TMP_FSF}"
    exit 1
  fi
  if [ ! -f "${d}/reg_standard/mask" ] && [ ! -f "${d}/reg_standard/mask.nii.gz" ]; then
    echo "ERROR: Missing reg_standard mask for sub-${i}: ${d}/reg_standard/mask"
    echo "Fix by running: $FSLDIR/bin/featregapply ${d}"
    rm -f "${TMP_FSF}"
    exit 1
  fi
  feat_dirs+=("${d}")
done

N="${#feat_dirs[@]}"

# Update counts
sed -i '' "s|^set fmri(npts).*|set fmri(npts) ${N}|g" "${TMP_FSF}"
sed -i '' "s|^set fmri(multiple).*|set fmri(multiple) ${N}|g" "${TMP_FSF}"

# Remove input dependent lines
sed -i '' '/^set feat_files(/d' "${TMP_FSF}"
sed -i '' '/^set fmri(evg[0-9]\+\.[0-9]\+)/d' "${TMP_FSF}"
sed -i '' '/^set fmri(groupmem\.[0-9]\+)/d' "${TMP_FSF}"

# Append feat_files
idx=1
for d in "${feat_dirs[@]}"; do
  echo "set feat_files(${idx}) \"${d}\"" >> "${TMP_FSF}"
  idx=$((idx+1))
done

# One group EV
for idx in $(seq 1 "${N}"); do
  echo "set fmri(evg${idx}.1) 1.0" >> "${TMP_FSF}"
done

# Group membership
for idx in $(seq 1 "${N}"); do
  echo "set fmri(groupmem.${idx}) 1" >> "${TMP_FSF}"
done

echo "Running FEAT with temp FSF: ${TMP_FSF}"
echo "Output will be written to: ${OUTPUT_DIR}"

feat "${TMP_FSF}"

rm -f "${TMP_FSF}"
echo "Done."
