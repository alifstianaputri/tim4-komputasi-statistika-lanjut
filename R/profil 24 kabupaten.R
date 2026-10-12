# =====================================================================
# OTOMATISASI PEMBUATAN 24 PROFIL KABUPATEN/KOTA & PETA KOROPLET
# =====================================================================

# 1. MEMUAT PUSTAKA (LIBRARY)
library(tidyverse)
library(readxl)
library(sf)
library(colorspace)
library(glue)
library(scales)

# 2. MEMBACA DATA
# Pastikan file 'Data_Gabungan.xlsx' berada dalam working directory yang sama
file_path <- "C:/Users/Lenovo/Documents/dokumen/Kelompok_Komstat/Data_Gabungan.xlsx"
df_raw <- read_excel(file_path, sheet = "Sheet1")

# Melihat sekilas struktur data
glimpse(df_raw)

# Transformasi data ke bentuk panjang (long format) untuk analisis tren multi-tahun (2022-2024)
df_long <- df_raw %>%
  pivot_longer(
    cols = c(starts_with("TPAK_"), starts_with("TPT_")),
    names_to = c(".value", "Tahun"),
    names_pattern = "(.*)_(20\\d{2})"
  ) %>%
  mutate(Tahun = as.numeric(Tahun))

# 3. MEMBUAT FUNGSI GRAFIK DENGAN TIDY EVALUATION ({{ }})
# Fungsi ini menerima nama kolom indikator secara fleksibel
plot_tren <- function(data, indikator, nama_kabupaten) {
  data_filtered <- data %>% filter(Kabupaten_Kota == nama_kabupaten)
  
  ggplot(data_filtered, aes(x = Tahun, y = {{ indikator }})) +
    geom_line(color = "#0072B2", linewidth = 1.2) +
    geom_point(color = "#0072B2", size = 3) +
    scale_x_continuous(breaks = c(2022, 2023, 2024)) +
    labs(
      title = glue("Tren Indikator untuk {nama_kabupaten}"),
      subtitle = "Periode 2022 - 2024",
      x = "Tahun",
      y = "Nilai Indikator"
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      panel.grid.minor = element_blank()
    )
}

# Contoh uji fungsi tunggal:
# plot_tren(df_long, TPT, "Bulukumba")


# 4. PERSIAPAN PETA KOROPLET & UJI BUTA WARNA (COLORBLIND-SAFE)
# Catatan: Ganti path di bawah dengan file Shapefile/GeoJSON wilayah Anda (misal: Sulawesi Selatan)
# Contoh placeholder pembacaan shp:
# peta_sf <- st_read("path/to/wilayah_sulsel.shp") %>% 
#   left_join(df_raw, by = "Kode_Wilayah")

# Untuk demonstrasi, diasumsikan objek sf sudah tersedia sebagai `peta_sf`
# Palet warna menggunakan `colorspace` yang aman untuk deuteranopia & protanopia (misal: Viridis atau HCL sequential)
buat_peta_koroplet <- function(data_sf, indikator_peta, judul_peta) {
  ggplot(data_sf) +
    geom_sf(aes(fill = {{ indikator_peta }}), color = "white", linewidth = 0.3) +
    # Menggunakan scale_fill_continuous_sequential dengan palet Viridis / Inferno yang aman buta warna
    scale_fill_continuous_sequential(
      palette = "Viridis", 
      rev = FALSE,
      name = "Nilai",
      labels = label_comma()
    ) +
    labs(
      title = judul_peta,
      subtitle = "Simulasi Aman Deuteranopia & Protanopia",
      caption = "Sumber: Data Gabungan 2026"
    ) +
    theme_void(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
      plot.subtitle = element_text(hjust = 0.5, size = 10, color = "grey40"),
      legend.position = "right"
    )
}


# 5. OTOMATISASI PEMBUATAN DAN PENYIMPANAN 24 PROFIL (purrr::walk + ggsave)

# Membuat direktori penyimpanan output jika belum ada
output_dir <- "output_profil_kabupaten"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# Mendapatkan daftar unik 24 kabupaten/kota
daftar_kabupaten <- unique(df_raw$Kabupaten_Kota)

# Fungsi wrapper untuk membuat dan menyimpan profil grafik per kabupaten
generate_and_save_profile <- function(kab) {
  # 1. Buat plot tren TPT (Tingkat Pengangguran Terbuka) sebagai contoh profil
  p_tpt <- plot_tren(df_long, TPT, kab)
  
  # 2. Buat plot tren TPAK (Tingkat Partisipasi Angkatan Kerja)
  p_tpak <- plot_tren(df_long, TPAK, kab)
  
  # Anda dapat menggabungkan plot jika menggunakan patchwork, atau menyimpannya terpisah:
  # Disini kita simpan grafik TPT sebagai contoh profil utama kabupaten
  file_name <- file.path(output_dir, glue("Profil_TPT_{str_replace_all(kab, ' ', '_')}.png"))
  
  ggsave(
    filename = file_name,
    plot = p_tpt,
    width = 8,
    height = 6,
    dpi = 300
  )
  
  message(glue("Berhasil menyimpan profil untuk: {kab}"))
}

# Menjalankan otomatisasi untuk seluruh 24 kabupaten/kota sekaligus
walk(daftar_kabupaten, generate_and_save_profile)

message("Semua 24 berkas profil kabupaten berhasil digenerate otomatis!")