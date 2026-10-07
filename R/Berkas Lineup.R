# ==============================================================================
# 1. LOAD LIBRARY & SETUP DATA DUMMY
# ==============================================================================
install.packages("tidyverse")
install.packages("nullabor")
library(tidyverse)
library(nullabor) # Untuk lineup plot

set.seed(123)
wilayah_list <- c("Bantaeng", "Barru", "Bone", "Bulukumba", "Enrekang", "Gowa", 
                  "Jeneponto", "Kepulauan Selayar", "Luwu", "Luwu Timur", 
                  "Luwu Utara", "Makassar", "Maros", "Palopo", "Pangkep", 
                  "Pare Pare", "Pinrang", "Sidrap", "Sinjai", "Soppeng", 
                  "Takalar", "Tana Toraja", "Toraja Utara", "Wajo")

data_labor <- expand.grid(
  wilayah = wilayah_list,
  tahun = c(2022, 2023, 2024)
) %>% 
  mutate(
    tahun = factor(tahun),
    TPAK = rnorm(n(), mean = 68, sd = 7),
    TPT = rnorm(n(), mean = 4, sd = 2)
  )

# ==============================================================================
# 2. FUNGSI GRAFIK MENGGUNAKAN {{ }} (TIDYEVAL)
# ==============================================================================

# Fungsi 1: Violin Plot + Boxplot + Jitter Points (seperti Gambar 1 & 3)
plot_distribusi <- function(data, x_var, y_var) {
  ggplot(data, aes(x = {{ x_var }}, y = {{ y_var }}, fill = {{ x_var }})) +
    geom_violin(alpha = 0.6, color = NA) +
    geom_boxplot(width = 0.2, fill = "white", outlier.shape = NA, alpha = 0.7) +
    geom_jitter(width = 0.08, alpha = 0.7, color = "black", size = 1.5) +
    scale_fill_manual(values = c("#6baed6", "#66c2a5", "#fec44f")) +
    theme_minimal(base_size = 12) +
    theme(
      legend.position = "none",
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold")
    )
}

# Fungsi 2: Scatterplot Regresi Linier (seperti Gambar 4)
plot_hubungan <- function(data, x_var, y_var, label_var) {
  ggplot(data, aes(x = {{ x_var }}, y = {{ y_var }})) +
    geom_smooth(method = "lm", color = "#2b5c8f", fill = "grey80", alpha = 0.5) +
    geom_point(color = "#31a354", size = 2.5) +
    ggrepel::geom_text_repel(aes(label = {{ label_var }}), size = 3) +
    theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold")
    )
}

# Contoh pengujian fungsi:
# plot_distribusi(data_labor, x_var = tahun, y_var = TPAK)
# plot_hubungan(filter(data_labor, tahun == 2024), x_var = TPAK, y_var = TPT, label_var = wilayah)

# ==============================================================================
# 3. MENYIAPKAN 20 PANEL LINEUP & KELUARAN BERKAS
# ==============================================================================

# a. Buat data nullabor untuk pengujian korelasi/regresi TPAK vs TPT (Tahun 2024)
data_2024 <- data_labor %>% filter(tahun == "2024")

# Mengacak posisi plot asli di antara 19 plot null (rotasi acak)
set.seed(2026)
lineup_data <- lineup(null_permute("TPT"), data_2024, n = 20)

# Catat/dapatkan posisi rahasia plot asli (True Plot ID)
true_plot_id <- attr(lineup_data, "pos")

# b. Plot Lineup 20 Panel
p_lineup <- ggplot(lineup_data, aes(x = TPAK, y = TPT)) +
  geom_smooth(method = "lm", color = "#2b5c8f", fill = "grey80", alpha = 0.4, se = TRUE) +
  geom_point(color = "#31a354", size = 1.5) +
  facet_wrap(~ .sample, ncol = 5) +
  labs(
    title = "Lineup Protocol (20 Panels) - Evaluasi Visual Korelasi TPAK vs TPT",
    subtitle = "Salah satu panel adalah data asli, 19 panel lainnya adalah data permutasian (null hypothesis)",
    x = "TPAK (%)",
    y = "TPT (%)"
  ) +
  theme_bw(base_size = 10) +
  theme(
    strip.background = element_rect(fill = "grey95"),
    plot.title = element_text(face = "bold")
  )

# Tampilkan plot lineup di RStudio
print(p_lineup)

# c. Simpan Berkas Plot Lineup
ggsave(
  filename = "lineup_20_panel.png", 
  plot = p_lineup, 
  width = 12, 
  height = 9, 
  dpi = 300
)

# d. Simpan Kunci Jawaban (Posisi Plot Asli) ke dalam Berkas Teks
writeLines(
  text = paste0("Posisi data asli (True Plot ID) berada di panel nomor: ", true_plot_id),
  con = "kunci_jawaban_lineup.txt"
)

