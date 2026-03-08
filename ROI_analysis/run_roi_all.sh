#!/bin/bash
set -euo pipefail

PARTICIPANTS_TSV="participants.tsv"
COPES=(1 3 5)

MASKS=("right_crus_I.nii.gz" "auditory_cortex.nii.gz")

if [ ! -f "$PARTICIPANTS_TSV" ]; then
  echo "ERROR: participants.tsv not found"
  exit 1
fi

cope_name() {
  case $1 in
    1) echo "sentences" ;;
    3) echo "words" ;;
    5) echo "reversed" ;;
  esac
}

for MASK_FILE in "${MASKS[@]}"; do

  MASK_PATH="ROI_analysis/masks/${MASK_FILE}"
  REGION_NAME="${MASK_FILE%.nii.gz}"

  OUT_ROOT="ROI_analysis_output/${REGION_NAME}"
  OUT_PLOTS="${OUT_ROOT}/plots"
  OUT_FILES="${OUT_ROOT}/files"

  mkdir -p "$OUT_PLOTS" "$OUT_FILES"

  if [ ! -f "$MASK_PATH" ]; then
    echo "WARNING: mask not found, skipping: $MASK_PATH"
    continue
  fi

  echo "Processing mask: $MASK_FILE"

  # ----------------------------
  # Part 1: Extract ROI means
  # ----------------------------
  for cope in "${COPES[@]}"; do
    label=$(cope_name $cope)
    out="${OUT_FILES}/roi_activation_${REGION_NAME}_${label}.csv"
    : > "$out"

    for s in sub-*; do
      id=$(basename "$s")
      featdir="$s/func/${id}_task-speech_bold.feat"
      cope_path="$featdir/reg_standard/stats/cope${cope}.nii.gz"

      if [ -f "$cope_path" ]; then
        val=$(fslmeants -i "$cope_path" -m "$MASK_PATH")
        echo "$id,$val" >> "$out"
      else
        echo "$id,NA" >> "$out"
      fi
    done

    echo "Wrote $out"
  done
