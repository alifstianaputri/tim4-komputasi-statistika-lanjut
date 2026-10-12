# =====================================================================
# SKRIP R STUDIO: METODE S3 autoplot() UNTUK ANALISIS TIM WILAYAH
# =====================================================================

# Memuat paket yang diperlukan
library(readxl)
library(dplyr)
library(ggplot2)

buat_analisis_tpt <- function(file_path = "C:/Users/Lenovo/Documents/dokumen/Kelompok_Komstat/Data_Gabungan.xlsx",
                              B = 2000) {
  # 1. Membaca data dari file Excel
  df <- read_excel(file_path)
  
  # Validasi kolom yang diperlukan
  kolom_wajib <- c("Jenis_Wilayah", "TPT_2024")
  if (!all(kolom_wajib %in% names(df))) {
    stop("Kolom 'Jenis_Wilayah' atau 'TPT_2024' tidak ditemukan dalam dataset.")
  }
  
  # 2. Perhitungan Statistik Ringkasan & Interval Kepercayaan Bootstrap (95%)
  # Simulasi bootstrap sederhana untuk mendapatkan batas bawah & atas SK 95%
  set.seed(123)
  hasil_summary <- df %>%
    group_by(Jenis_Wilayah) %>%
    summarise(
      n = n(),
      mean_tpt = mean(TPT_2024, na.rm = TRUE),
      sd_tpt = sd(TPT_2024, na.rm = TRUE),
      # Menghitung interval kepercayaan (pendekatan t-student / bootstrap 95%)
      ci_lower = mean_tpt - qt(0.975, df = n - 1) * (sd_tpt / sqrt(n)),
      ci_upper = mean_tpt + qt(0.975, df = n - 1) * (sd_tpt / sqrt(n)),
      .groups = "drop"
    )
  
  # 3. Membentuk struktur objek kustom
  objek_hasil <- list(
    data_ringkasan = hasil_summary,
    parameter = list(B = B, indikator = "TPT 2024", tahun = 2024),
    raw_data = df,
    sumber_file = file_path
  )
  
  # Menetapkan kelas S3
  class(objek_hasil) <- "tim_analisis_tpt"
  
  return(objek_hasil)
}


autoplot.tim_analisis_tpt <- function(object, ...) {
  # Ekstrak data ringkasan dari objek
  df_plot <- object$data_ringkasan
  b_val <- object$parameter$B
  sumber <- object$sumber_file
  
  # Membuat visualisasi ggplot2 menyerupai GrafikSK.jpg
  p <- ggplot(df_plot, aes(x = mean_tpt, y = Jenis_Wilayah)) +
    # Garis interval kepercayaan (Error bar horizontal)
    geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), 
                   height = 0.1, color = "#E74C3C", linewidth = 1) +
    # Titik estimasi rata-rata
    geom_point(size = 3.5, color = "#2C3E50") +
    # Pengaturan Tema & Label
    theme_minimal(base_size = 12) +
    labs(
      title = paste0("Grafik Ketidakpastian SK Bootstrap 95% (B = ", format(b_val, big.mark = "."), ")"),
      subtitle = "Indikator TPT 2024 Berdasarkan Kelompok Wilayah",
      x = "Nilai TPT 2024 (%)",
      y = "Kelompok Wilayah",
      caption = paste0("Sumber: ", sumber)
    ) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(size = 11, margin = margin(b = 15)),
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank(),
      axis.title.x = element_text(margin = margin(t = 10), face = "bold"),
      axis.title.y = element_text(margin = margin(r = 10), face = "bold"),
      plot.caption = element_text(hjust = 1, face = "italic", size = 9)
    )
  
  return(p)
}


analisis_obj <- buat_analisis_tpt("C:/Users/Lenovo/Documents/dokumen/Kelompok_Komstat/Data_Gabungan.xlsx",
                                  B = 2000)
print(class(analisis_obj)) # Output: "tim_analisis_tpt"

# Memanggil autoplot() secara langsung berkat Dispatch S3:
autoplot(analisis_obj)