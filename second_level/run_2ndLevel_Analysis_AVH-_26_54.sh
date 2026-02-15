#!/bin/bash
set -euo pipefail

ROOT_DIR="$(pwd)"

BASE_FSF="${ROOT_DIR}/second_level/design_run_AVH-_26_54.fsf"
if [ ! -f "${BASE_FSF}" ]; then
  echo "ERROR: Cannot find base FSF at: ${BASE_FSF}"
  exit 1
fi

TMP_FSF="$(mktemp "${ROOT_DIR}/second_level/tmp_design_AVH-_26_54_XXXXXX.fsf")"
cp "${BASE_FSF}" "${TMP_FSF}"

# Force output directory
OUTPUT_DIR="${ROOT_DIR}/second_level_output/avh-.gfeat"
mkdir -p "${ROOT_DIR}/second_level_output"

sed -i '' "s|^set fmri(outputdir).*|set fmri(outputdir) \"${OUTPUT_DIR}\"|g" "${TMP_FSF}"

feat_dirs=()

# Build inputs sub-26..sub-54
for i in $(seq -w 26 54); do
  d="${ROOT_DIR}/sub-${i}/func/sub-${i}_task-speech_bold.feat"

  # Skip missing subjects
  if [ ! -d "${d}" ]; then
    echo "Skipping sub-${i} (FEAT directory not found)"
    continue
  fi

  # Ensure reg_standard exists
  if [ ! -f "${d}/reg_standard/mask" ] && [ ! -f "${d}/reg_standard/mask.nii.gz" ]; then
    echo "Creating reg_standard for sub-${i}"
    "${FSLDIR}/bin/featregapply" "${d}"
  fi

  # Skip if still missing
  if [ ! -f "${d}/reg_standard/mask" ] && [ ! -f "${d}/reg_standard/mask.nii.gz" ]; then
    echo "Skipping sub-${i} (reg_standard mask still missing)"
    continue
  fi

  feat_dirs+=("${d}")
done

N="${#feat_dirs[@]}"

if [ "${N}" -eq 0 ]; then
  echo "ERROR: No valid inputs found."
  exit 1
fi

echo "Using ${N} subjects for group analysis"

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

# One group EV: all ones
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
