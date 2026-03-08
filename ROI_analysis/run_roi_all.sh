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
    *) echo "unknown" ;;
  esac
}

for MASK_FILE in "${MASKS[@]}"; do
  MASK_PATH="ROI_analysis/masks/${MASK_FILE}"
  REGION_NAME="${MASK_FILE%.nii.gz}"

  OUT_ROOT="ROI_analysis_output/${REGION_NAME}"
  OUT_FILES="${OUT_ROOT}/files"

  mkdir -p "$OUT_FILES"

  if [ ! -f "$MASK_PATH" ]; then
    echo "WARNING: mask not found, skipping: $MASK_PATH"
    continue
  fi

  echo "Processing mask: $MASK_FILE"

  # ----------------------------
  # Part 1: Extract ROI means
  # ----------------------------
  for cope in "${COPES[@]}"; do
    label=$(cope_name "$cope")
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

  # ----------------------------
  # Part 2: Merge with participants.tsv
  # and impute missing IQ values with 100
  # ----------------------------
  python3 - << PY
import os
import pandas as pd

participants_tsv = "${PARTICIPANTS_TSV}"
out_files = "${OUT_FILES}"
region_name = "${REGION_NAME}"

copes = [1, 3, 5]
cope_map = {
    1: "sentences",
    3: "words",
    5: "reversed",
}

participants = pd.read_csv(participants_tsv, sep="\\t")

# Convert IQ to numeric and impute missing values with 100
participants["iq"] = pd.to_numeric(participants["iq"], errors="coerce")
participants["iq"] = participants["iq"].fillna(100)

for cope in copes:
    label = cope_map[cope]
    roi_csv = os.path.join(out_files, f"roi_activation_{region_name}_{label}.csv")

    if not os.path.exists(roi_csv):
        print("Skipping missing ROI file:", roi_csv)
        continue

    pe = pd.read_csv(
        roi_csv,
        header=None,
        names=["participant_id", "roi_activation"],
    )
    pe["roi_activation"] = pd.to_numeric(pe["roi_activation"], errors="coerce")

    merged = participants.merge(pe, on="participant_id", how="inner")

    merged_out = os.path.join(out_files, f"merged_{region_name}_{label}.csv")
    merged.to_csv(merged_out, index=False)

    print("Saved:", merged_out)
PY

done