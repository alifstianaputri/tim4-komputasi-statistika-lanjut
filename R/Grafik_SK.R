# 1. Install dan Load Pustaka yang Dibutuhkan
# install.packages(c("readxl", "dplyr", "boot", "ggplot2", "forcats"))
library(readxl)
library(dplyr)
library(boot)
library(ggplot2)
library(forcats)

# 2. Impor Data
df <- read_excel("C:/Users/Lenovo/Documents/dokumen/Kelompok_Komstat/Data_Gabungan.xlsx")

# 3. Fungsi Statistik untuk Bootstrap (Rata-rata)
boot_mean <- function(data, indices) {
  return(mean(data[indices], na.rm = TRUE))
}

# Set seed untuk reproduksibilitas
set.seed(2026)
B_repl <- 2000

# 4. Melakukan Bootstrap per Kelompok Wilayah (Contoh: Indikator TPT_2024)
hasil_bootstrap <- df %>%
  group_by(Jenis_Wilayah) %>%
  summarise(
    Mean = mean(TPT_2024, na.rm = TRUE),
    N = n(),
    # Menjalankan fungsi boot
    BootObj = list(boot(data = TPT_2024, statistic = boot_mean, R = B_repl)),
    .groups = "drop"
  ) %>%
  rowwise() %>%
  mutate(
    # Ekstraksi Persentil SK 95% dari objek boot
    CI_Lower = boot.ci(BootObj, type = "perc")$percent[4],
    CI_Upper = boot.ci(BootObj, type = "perc")$percent[5]
  ) %>%
  ungroup() %>%
  select(-BootObj)

# 5. Menampilkan Tabel Hasil di Konsol RStudio
print(hasil_bootstrap)

# 6. Membuat Grafik Titik + Garis Galat yang Diurutkan
ggplot(hasil_bootstrap, aes(x = fct_reorder(Jenis_Wilayah, Mean), y = Mean)) +
  geom_point(size = 4, color = "#2c3e50") +
  geom_errorbar(aes(ymin = CI_Lower, ymax = CI_Upper), width = 0.2, linewidth = 1, color = "#e74c3c") +
  coord_flip() +
  labs(
    title = "Grafik Ketidakpastian SK Bootstrap 95% (B = 2.000)",
    subtitle = "Indikator TPT 2024 Berdasarkan Kelompok Wilayah",
    x = "Kelompok Wilayah",
    y = "Nilai TPT 2024 (%)",
    caption = "Sumber: Data_Gabungan.xlsx"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank()
  )