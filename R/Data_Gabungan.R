# ============================================================
# Gabung TPAK, TPT, Kode Wilayah + GeoJSON -> .xlsx dan .rds
# Folder: C:/Users/Lenovo/Documents/dokumen/Kelompok_Komstat
# (semua file input ditaruh di folder ini)
# ============================================================

# install.packages(c("readxl", "dplyr", "writexl", "sf"))  # jalankan sekali jika belum ada
library(readxl)
library(dplyr)
library(writexl)
library(sf)

setwd("C:/Users/Lenovo/Documents/dokumen/Kelompok_Komstat")

# ---------- 1. Fungsi baca file Excel BPS ----------
# 3 baris pertama adalah judul, data mulai baris ke-4
baca <- function(file, nama_kolom) {
  read_excel(file, skip = 3, col_names = c("Kabupaten_Kota", nama_kolom)) %>%
    mutate(across(all_of(nama_kolom), as.numeric))
}

tpak22 <- baca("TPAK22.xlsx", "TPAK_2022")
tpak23 <- baca("TPAK23.xlsx", "TPAK_2023")
tpak24 <- baca("TPAK24.xlsx", "TPAK_2024")
tpt22  <- baca("TPT22.xlsx",  "TPT_2022")
tpt23  <- baca("TPT23.xlsx",  "TPT_2023")
tpt24  <- baca("TPT24.xlsx",  "TPT_2024")

# ---------- 2. Gabungkan semua Excel ----------
data <- tpak22 %>%
  left_join(tpak23, by = "Kabupaten_Kota") %>%
  left_join(tpak24, by = "Kabupaten_Kota") %>%
  left_join(tpt22,  by = "Kabupaten_Kota") %>%
  left_join(tpt23,  by = "Kabupaten_Kota") %>%
  left_join(tpt24,  by = "Kabupaten_Kota") %>%
  filter(Kabupaten_Kota != "SULAWESI SELATAN")   # buang baris total provinsi

# ---------- 3. Samakan nama wilayah dengan Kode Wilayah ----------
# Nama di file BPS disingkat (Pangkep, Sidrap, Pare Pare), jadi disamakan dulu
buat_kunci <- function(x) {
  x <- tolower(trimws(x))
  x <- sub("^kota ", "", x)
  x[x == "pangkep"]   <- "pangkajene dan kepulauan"
  x[x == "sidrap"]    <- "sidenreng rappang"
  x[x == "pare pare"] <- "parepare"
  x
}

kode <- read_excel("Kode_Wilayah.xlsx") %>%
  select(Kode_Wilayah = `Kode Wilayah BPS`,
         Nama_Resmi   = `Kabupaten/Kota`,
         Jenis_Wilayah = `Jenis Wilayah`) %>%
  mutate(kunci = buat_kunci(Nama_Resmi))

data <- data %>%
  mutate(kunci = buat_kunci(Kabupaten_Kota)) %>%
  left_join(kode, by = "kunci") %>%
  select(Kode_Wilayah, Kabupaten_Kota, Nama_Resmi, Jenis_Wilayah, kunci,
         starts_with("TPAK"), starts_with("TPT"))

# ---------- 4. Simpan hasil gabungan Excel ----------
write_xlsx(select(data, -kunci), "Data_Gabungan.xlsx")

# ---------- 5. Gabungkan dengan GeoJSON ----------
peta <- st_read("geoBoundaries.geojson", quiet = TRUE) %>%
  mutate(kunci = buat_kunci(shapeName))

# left_join dari data -> hanya 24 kab/kota Sulsel yang ikut
peta_sulsel <- peta %>%
  select(kunci, geometry) %>%
  inner_join(data, by = "kunci") %>%
  select(-kunci)

# Cek: harus 24 baris
print(nrow(peta_sulsel))
print(peta_sulsel)

# ---------- 6. Simpan ke .rds ----------
saveRDS(peta_sulsel, "Data_Sulsel.rds")

# Cara membuka lagi:
# peta_sulsel <- readRDS("C:/Users/Lenovo/Documents/dokumen/Kelompok_Komstat/Data_Sulsel.rds")