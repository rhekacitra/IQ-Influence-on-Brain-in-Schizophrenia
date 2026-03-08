# ----------------------------
# Merge + Plot
# ----------------------------
python3 - << PY
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy import stats

participants_tsv = "${PARTICIPANTS_TSV}"
out_files = "${OUT_FILES}"
out_plots = "${OUT_PLOTS}"
region_name = "${REGION_NAME}"

copes = [1,3,5]

cope_map = {
    1: "sentences",
    3: "words",
    5: "reversed",
}

contrast_label = {
    1: "Contrast: Sentences",
    3: "Contrast: Words",
    5: "Contrast: Reversed",
}

participants = pd.read_csv(participants_tsv, sep="\\t")

FIXED_N = {"HC": 25, "AVH+": 23, "AVH-": 23}

for cope in copes:
    label = cope_map[cope]

    roi_csv = os.path.join(out_files, f"roi_activation_{region_name}_{label}.csv")

    pe = pd.read_csv(
        roi_csv,
        header=None,
        names=["participant_id", "roi_activation"],
    )
    pe["roi_activation"] = pd.to_numeric(pe["roi_activation"], errors="coerce")

    merged = participants.merge(pe, on="participant_id", how="inner")

    merged_out = os.path.join(out_files, f"merged_{region_name}_{label}.csv")
    merged.to_csv(merged_out, index=False)

    fig, ax = plt.subplots(figsize=(8, 6))
    fig.patch.set_facecolor("white")
    ax.set_facecolor("white")

    groups = {
        "HC":   {"color": "#110eec", "label": "Healthy Controls"},
        "AVH+": {"color": "#de4a4a", "label": "AVH Positive"},
        "AVH-": {"color": "#20b743", "label": "AVH Negative"},
    }

    for g, conf in groups.items():
        subset = merged[merged["group"] == g].copy()
        subset["iq"] = pd.to_numeric(subset["iq"], errors="coerce")
        subset["roi_activation"] = pd.to_numeric(subset["roi_activation"], errors="coerce")
        subset = subset.replace([np.inf, -np.inf], np.nan).dropna(subset=["iq", "roi_activation"])

        if len(subset) < 3 or subset["iq"].nunique() < 2:
            continue

        x = subset["iq"].to_numpy()
        y = subset["roi_activation"].to_numpy()

        slope, intercept, r_value, p_value, std_err = stats.linregress(x, y)
        n_disp = FIXED_N.get(g, len(x))

        ax.scatter(
            x, y,
            color=conf["color"],
            alpha=0.7,
            s=50,
            edgecolors="black",
            linewidths=0.5,
            zorder=3,
            label=f'{conf["label"]} ({g}, n={n_disp}): β={slope:.2f}±{std_err:.2f}, r={r_value:.2f}, p={p_value:.3f}'
        )

        xs = np.linspace(x.min(), x.max(), 200)
        y_hat = slope * xs + intercept

        n = len(x)
        x_mean = x.mean()
        se_fit = np.sqrt(
            (np.sum((y - (slope * x + intercept)) ** 2) / (n - 2))
            * (1 / n + (xs - x_mean) ** 2 / np.sum((x - x_mean) ** 2))
        )
        t_crit = stats.t.ppf(0.975, df=n - 2)

        ax.fill_between(xs, y_hat - t_crit*se_fit, y_hat + t_crit*se_fit,
                        color=conf["color"], alpha=0.1, zorder=1)
        ax.plot(xs, y_hat, color=conf["color"], linewidth=2, zorder=2)

    ax.set_xlabel("IQ Score")
    ax.set_ylabel("Activation")
    ax.set_title(f"IQ and {region_name.replace('_',' ').title()} Activation", fontsize=14, fontweight="bold")

    ax.text(
        0.5, 1.05,
        contrast_label[cope],
        transform=ax.transAxes,
        ha="center",
        fontsize=11,
        color="dimgray"
    )

    ax.grid(True, alpha=0.15)
    ax.legend(fontsize=8)

    plt.tight_layout()

    png_out = os.path.join(out_plots, f"iq_vs_{region_name}_{label}.png")
    plt.savefig(png_out, dpi=200, bbox_inches="tight", facecolor="white")
    plt.close(fig)

    print("Saved:", merged_out)
    print("Saved:", png_out)
PY

done
