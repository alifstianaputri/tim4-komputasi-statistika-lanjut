# Instal paket jika belum tersedia
# install.packages(c("tidyverse", "readxl", "patchwork", "ggrepel"))

library(tidyverse)
library(readxl)
library(patchwork)
library(ggrepel)

# 1. Membaca data dari file Excel
df_raw <- read_excel("C:/Users/Lenovo/Documents/dokumen/Kelompok_Komstat/Data_Gabungan.xlsx")

# 2. Reshape data TPAK dari wide ke long
df_tpak <- df_raw %>%
  select(Kode_Wilayah, Kabupaten_Kota, Jenis_Wilayah, TPAK_2022, TPAK_2023, TPAK_2024) %>%
  pivot_longer(
    cols = starts_with("TPAK_"),
    names_to = "Tahun",
    names_prefix = "TPAK_",
    values_to = "TPAK"
  ) %>%
  mutate(Tahun = as.numeric(Tahun))

# 3. Reshape data TPT dari wide ke long
df_tpt <- df_raw %>%
  select(Kode_Wilayah, Kabupaten_Kota, Jenis_Wilayah, TPT_2022, TPT_2023, TPT_2024) %>%
  pivot_longer(
    cols = starts_with("TPT_"),
    names_to = "Tahun",
    names_prefix = "TPT_",
    values_to = "TPT"
  ) %>%
  mutate(Tahun = as.numeric(Tahun))

# 4. Gabungkan kembali ke dalam satu dataframe long yang komprehensif
df_long <- df_tpak %>%
  left_join(df_tpt, by = c("Kode_Wilayah", "Kabupaten_Kota", "Jenis_Wilayah", "Tahun"))

# Palet Warna Tematik (Tim Palette)
palet_tim <- c(
  "2022" = "#3498DB", 
  "2023" = "#16A085", 
  "2024" = "#F1C40F",
  "Primary" = "#8E44AD",
  "Accent"  = "#E91E63",
  "Highlight" = "#E74C3C"
)

# Fungsi Tema Kustom
theme_tim <- function(base_size = 11, base_family = "") {
  theme_minimal(base_size = base_size, base_family = base_family) +
    theme(
      plot.title = element_text(face = "bold", size = rel(1.2), color = "#2C3E50", hjust = 0, margin = margin(b = 10)),
      plot.subtitle = element_text(size = rel(0.95), color = "#7F8C8D", hjust = 0, margin = margin(b = 15)),
      plot.caption = element_text(size = rel(0.75), color = "#95A5A6", hjust = 1, margin = margin(t = 15)),
      panel.grid.major = element_line(color = "#ECF0F1", linewidth = 0.5),
      panel.grid.minor = element_blank(),
      axis.title = element_text(face = "bold", size = rel(0.9), color = "#34495E"),
      axis.text = element_text(size = rel(0.85), color = "#2C3E50"),
      legend.position = "bottom",
      legend.title = element_text(face = "bold", size = rel(0.9)),
      legend.text = element_text(size = rel(0.85)),
      plot.background = element_rect(fill = "#FFFFFF", color = NA),
      panel.background = element_rect(fill = "#FFFFFF", color = NA)
    )
}

# Grafik 1: Sebaran TPAK per Tahun (Violin Plot + Boxplot + Titik)
p1 <- ggplot(df_long, aes(x = factor(Tahun), y = TPAK, fill = factor(Tahun))) +
  geom_violin(trim = FALSE, alpha = 0.6, color = NA) +
  geom_boxplot(width = 0.15, color = "#2C3E50", fill = "white", alpha = 0.8, outlier.shape = NA) +
  geom_jitter(width = 0.1, size = 2, color = "#2C3E50", alpha = 0.7) +
  scale_fill_manual(values = palet_tim) +
  labs(
    title = "Distribusi TPAK Antar Wilayah (2022 - 2024)",
    subtitle = "Gabungan Violin Plot, Boxplot, dan Titik Observasi",
    x = "Tahun",
    y = "TPAK (%)",
    fill = "Tahun"
  ) +
  theme_tim() +
  guides(fill = "none")

print(p1)

# Grafik 2: Sebaran TPT per Tahun (Violin Plot + Boxplot + Titik)
p2 <- ggplot(df_long, aes(x = factor(Tahun), y = TPT, fill = factor(Tahun))) +
  geom_violin(trim = FALSE, alpha = 0.6, color = NA) +
  geom_boxplot(width = 0.15, color = "#2C3E50", fill = "white", alpha = 0.8, outlier.shape = NA) +
  geom_jitter(width = 0.1, size = 2, color = "#2C3E50", alpha = 0.7) +
  scale_fill_manual(values = palet_tim) +
  labs(
    title = "Distribusi TPT Antar Wilayah (2022 - 2024)",
    subtitle = "Penyebaran Tingkat Pengangguran Terbuka",
    x = "Tahun",
    y = "TPT (%)",
    fill = "Tahun"
  ) +
  theme_tim() +
  guides(fill = "none")

print(p2)

# Grafik 3: Tren Waktu dengan Small Multiples 24 Wilayah (facet_wrap)
# Transformasi data untuk facet time-series gabungan
df_trend <- df_long %>%
  select(Kabupaten_Kota, Tahun, TPAK, TPT) %>%
  pivot_longer(cols = c(TPAK, TPT), names_to = "Indikator", values_to = "Nilai")

p3 <- ggplot(df_trend, aes(x = Tahun, y = Nilai, color = Indikator, group = Indikator)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.5) +
  facet_wrap(~ Kabupaten_Kota, ncol = 6, scales = "free_y") +
  scale_color_manual(values = c("TPAK" = "#16A085", "TPT" = "#E74C3C")) +
  labs(
    title = "Tren Waktu TPAK dan TPT di 24 Wilayah",
    subtitle = "Small Multiples per Kabupaten/Kota",
    x = "Tahun",
    y = "Persentase (%)",
    color = "Indikator"
  ) +
  theme_tim() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = rel(0.7)),
    strip.text = element_text(face = "bold", size = rel(0.75)),
    legend.position = "bottom"
  )

print(p3)

# Grafik 4: Scatterplot Hubungan TPAK vs TPT (Tahun 2024) + Garis Regresi & Pita SK
df_2024 <- df_long %>% filter(Tahun == 2024)

p4 <- ggplot(df_2024, aes(x = TPAK, y = TPT, label = Kabupaten_Kota)) +
  geom_point(color = "#16A085", size = 3, alpha = 0.8) +
  geom_smooth(method = "lm", color = "#2C3E50", fill = "#BDC3C7", alpha = 0.3, linewidth = 1) +
  geom_text_repel(size = 3, box.padding = 0.3, max.overlaps = 15) +
  labs(
    title = "Hubungan TPAK dan TPT Tahun 2024",
    subtitle = "Scatterplot dengan Garis Regresi Linier dan Pita Selang Kepercayaan (SK 95%)",
    x = "TPAK (%)",
    y = "TPT (%)"
  ) +
  theme_tim()

print(p4)

# Grafik 5: Komposisi Multipanel dengan patchwork
# Membuat ringkasan rata-rata nasional/regional per tahun untuk panel tambahan
df_summary <- df_long %>%
  group_by(Tahun) %>%
  summarise(
    Rata_TPAK = mean(TPAK, na.rm = TRUE),
    Rata_TPT = mean(TPT, na.rm = TRUE)
  )

p_bar_tpak <- ggplot(df_summary, aes(x = factor(Tahun), y = Rata_TPAK, fill = factor(Tahun))) +
  geom_col(width = 0.6, alpha = 0.9) +
  scale_fill_manual(values = palet_tim) +
  labs(title = "Rata-rata TPAK", x = "", y = "TPAK (%)") +
  theme_tim() + guides(fill = "none")

p_bar_tpt <- ggplot(df_summary, aes(x = factor(Tahun), y = Rata_TPT, fill = factor(Tahun))) +
  geom_col(width = 0.6, alpha = 0.9) +
  scale_fill_manual(values = palet_tim) +
  labs(title = "Rata-rata TPT", x = "", y = "TPT (%)") +
  theme_tim() + guides(fill = "none")

# Menggabungkan p1, p4, p_bar_tpak, dan p_bar_tpt menggunakan patchwork
dashboard_multipanel <- (p_bar_tpak | p_bar_tpt) / (p1 + p4) +
  plot_annotation(
    title = "Dashboard Analisis Ketenagakerjaan Regional",
    subtitle = "Komposisi Multipanel Indikator Strategis",
    caption = "Sumber: Data Gabungan 2022-2024",
    theme = theme(
      plot.title = element_text(face = "bold", size = 16, color = "#2C3E50"),
      plot.subtitle = element_text(size = 12, color = "#7F8C8D")
    )
  )

print(dashboard_multipanel)