import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy import stats

COPES = [1, 3, 5]
REGIONS = ["right_crus_I", "auditory_cortex"]

COPE_MAP = {
    1: "sentences",
    3: "words",
    5: "reversed",
}

CONTRAST_LABEL = {
    1: "Contrast: Sentences",
    3: "Contrast: Words",
    5: "Contrast: Reversed",
}

FIXED_N = {
    "HC": 25,
    "AVH+": 23,
    "AVH-": 23,
}

GROUPS = {
    "HC":   {"color": "#110eec", "label": "Healthy Controls"},
    "AVH+": {"color": "#de4a4a", "label": "AVH Positive"},
    "AVH-": {"color": "#20b743", "label": "AVH Negative"},
}


def main():
    for region_name in REGIONS:
        out_root = os.path.join("ROI_analysis_output", region_name)
        out_files = os.path.join(out_root, "files")
        out_plots = os.path.join(out_root, "plots")

        os.makedirs(out_plots, exist_ok=True)

        for cope in COPES:
            label = COPE_MAP[cope]
            merged_csv = os.path.join(out_files, f"merged_{region_name}_{label}.csv")

            if not os.path.exists(merged_csv):
                print(f"Skipping missing merged file: {merged_csv}")
                continue

            merged = pd.read_csv(merged_csv)

            fig, ax = plt.subplots(figsize=(8, 6))
            fig.patch.set_facecolor("white")
            ax.set_facecolor("white")

            for g, conf in GROUPS.items():
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
                    label=(
                        f'{conf["label"]} ({g}, n={n_disp}): '
                        f'β={slope:.2f}±{std_err:.2f}, '
                        f'r={r_value:.2f}, p={p_value:.3f}'
                    )
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

                ax.fill_between(
                    xs,
                    y_hat - t_crit * se_fit,
                    y_hat + t_crit * se_fit,
                    color=conf["color"],
                    alpha=0.1,
                    zorder=1
                )
                ax.plot(xs, y_hat, color=conf["color"], linewidth=2, zorder=2)

            ax.set_xlabel("IQ Score")
            ax.set_ylabel("Activation")
            ax.set_title(
                f"IQ and {region_name.replace('_', ' ').title()} Activation",
                fontsize=14,
                fontweight="bold"
            )

            ax.text(
                0.5, 1.05,
                CONTRAST_LABEL[cope],
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

            print("Saved:", png_out)


if __name__ == "__main__":
    main()
