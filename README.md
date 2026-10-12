# Analisis TPAK dan TPT Sulawesi Selatan 2022-2024 dan 24 Profil Kabupaten/Kota

Proyek ini menganalisis **Tingkat Partisipasi Angkatan Kerja (TPAK)** dan **Tingkat Pengangguran Terbuka (TPT)** di 24 kabupaten/kota Sulawesi Selatan pada Agustus 2022 sampai 2024. Keluaran akhirnya adalah galeri grafik statistik, uji visual *lineup protocol*, selang kepercayaan bootstrap, serta **24 profil kabupaten/kota** yang dibuat otomatis di RStudio beserta **peta koroplet** ramah buta warna.

## Ringkasan Temuan

| Analisis | Hasil |
|---|---|
| Lineup 20 panel | Panel asli (panel 13) menunjukkan hubungan negatif TPAK dan TPT |
| Pilihan pengamat | 7 dari 13 pengamat memilih panel asli, p-value visual 1,03e-06 |
| Bootstrap 95% (B = 2.000) | TPT 2024: Kota sekitar 7,5% vs Kabupaten sekitar 3,2% |
| Korelasi TPAK-TPT 2024 | r sekitar -0,42 (24 wilayah) |

Rata-rata sederhana TPT 2024 pada `Data_Gabungan.xlsx` adalah 3,16% untuk 21 kabupaten dan 7,53% untuk 3 kota (Makassar, Pare Pare, Palopo). Angka ini konsisten dengan titik estimasi pada grafik bootstrap.

## Struktur Berkas

### Data

| Berkas | Isi |
|---|---|
| `TPAK22.xlsx`, `TPAK23.xlsx`, `TPAK24.xlsx` | Data mentah TPAK (Agustus, persen) per kabupaten/kota, satu berkas per tahun |
| `TPT22.xlsx`, `TPT23.xlsx`, `TPT24.xlsx` | Data mentah TPT (Agustus) per kabupaten/kota, satu berkas per tahun |
| `Kode_Wilayah.xlsx` | Daftar 24 wilayah beserta kode wilayah BPS dan jenis wilayah (Kabupaten/Kota) |
| `Data_Gabungan.xlsx` | Gabungan seluruh data mentah dalam format lebar (24 baris, 10 kolom, tanpa data kosong) |
| `Data_Sulsel.rds` | Objek data R untuk Sulawesi Selatan |
| `geoBoundaries.geojson` | Batas wilayah administrasi tingkat 2 (ADM2) untuk peta |

Kolom `Data_Gabungan.xlsx`:

| Kolom | Keterangan |
|---|---|
| `Kode_Wilayah` | Kode wilayah BPS (7301 sampai 7373) |
| `Kabupaten_Kota` | Nama singkat wilayah |
| `Nama_Resmi` | Nama resmi wilayah |
| `Jenis_Wilayah` | `Kabupaten` atau `Kota` |
| `TPAK_2022`, `TPAK_2023`, `TPAK_2024` | TPAK (%) per tahun |
| `TPT_2022`, `TPT_2023`, `TPT_2024` | TPT (%) per tahun |

### Skrip R

| Berkas | Fungsi |
|---|---|
| `Galeri_Grafik_Statistik.R` | Membaca `Data_Gabungan.xlsx`, mengubahnya ke format panjang, lalu membuat 5 grafik: sebaran TPAK dan TPT per tahun (violin, boxplot, titik), tren 24 wilayah (*small multiples*), scatterplot TPAK vs TPT 2024 dengan regresi dan pita SK 95%, serta dashboard multipanel dengan `patchwork` |
| `Berkas_Lineup.R` | Membuat fungsi grafik berbasis *tidy evaluation* (`{{ }}`) dan lineup 20 panel dengan `nullabor`, lalu menyimpan `lineup_20_panel.png` dan `kunci_jawaban_lineup.txt` |

### Grafik dan Infografis

| Berkas | Isi |
|---|---|
| `Lineup_Protocol__20_Panels_.jpg` | Lineup 20 panel TPAK vs TPT |
| `p_value_visual_hasil_lineup.png` | Rekap pilihan pengamat dan p-value visual |
| `GrafikSK.jpg` | Selang kepercayaan bootstrap 95% TPT 2024 menurut Kota dan Kabupaten |
| `infografis_tpt.png` | Infografis ringkasan tiga grafik di atas |

## Cara Menjalankan

1. Pasang paket yang dibutuhkan:

   ```r
   install.packages(c("tidyverse", "readxl", "patchwork", "ggrepel", "nullabor"))
   ```

2. Ubah jalur berkas pada `Galeri_Grafik_Statistik.R`. Skrip ini masih memakai jalur absolut Windows (`D:/KULIAH SASA/...`). Gunakan jalur relatif, misalnya `read_excel("Data_Gabungan.xlsx")`.
3. Jalankan `Galeri_Grafik_Statistik.R` untuk menghasilkan grafik 1 sampai 5.
4. Jalankan `Berkas_Lineup.R` untuk menghasilkan lineup 20 panel dan kunci jawabannya.

## 24 Profil Kabupaten/Kota dan Peta Koroplet

Wilayah yang dicakup: 21 kabupaten dan 3 kota (Makassar, Pare Pare, Palopo).

Alur kerja pembuatan profil otomatis:

1. Siapkan data indikator (`Data_Gabungan.xlsx`, `Data_Sulsel.rds`) dan batas wilayah (`geoBoundaries.geojson`).
2. Gabungkan data indikator dengan batas wilayah berdasarkan kode atau nama wilayah (`Kode_Wilayah.xlsx` sebagai kunci rujukan).
3. Buat peta koroplet dengan palet ramah buta warna, lalu uji tampilannya untuk kondisi buta warna.
4. Gunakan *loop* di R untuk membuat profil tiap wilayah (TPAK dan TPT 2022-2024, posisi pada peta, dan perbandingan antarwilayah).
5. Simpan **24 berkas profil** dan **satu berkas peta**, lalu periksa seluruh hasilnya.

Keluaran yang diharapkan:

```text
output/
├── profil/            # 24 berkas profil, satu per kabupaten/kota
└── peta_koroplet.png  # satu berkas peta
```

> Skrip untuk langkah 2 sampai 5 belum ada di berkas yang diunggah. Bagian ini adalah rancangan alur dan perlu disesuaikan setelah skripnya dibuat.

## Catatan Penting

- **`Berkas_Lineup.R` memakai data simulasi**, bukan `Data_Gabungan.xlsx`. TPAK dan TPT dibangkitkan dengan `rnorm()` (TPAK rata-rata 68 dan sd 7, TPT rata-rata 4 dan sd 2, `set.seed(123)`). Jika lineup untuk laporan harus memakai data asli, ganti `data_labor` dengan data dari `Data_Gabungan.xlsx` dan jalankan ulang.
- **Skrip bootstrap dan p-value visual tidak ada** di berkas yang diunggah. Grafik `GrafikSK.jpg` dan `p_value_visual_hasil_lineup.png` hanya tersedia sebagai gambar, sehingga angka selang kepercayaannya (sekitar 5,2 sampai 9,7 untuk Kota dan sekitar 2,7 sampai 3,7 untuk Kabupaten) dibaca dari gambar dan bersifat pendekatan.
- **`geoBoundaries.geojson` memuat 519 poligon ADM2 seluruh Indonesia**, sehingga perlu difilter ke 24 wilayah Sulawesi Selatan sebelum dipetakan. Nama pada kolom `shapeName` perlu dicocokkan dengan `Nama_Resmi`.
- Jumlah kota hanya 3, sehingga perbandingan Kota vs Kabupaten memiliki ketidakpastian besar (selang Kota lebar).
- Hasil lineup dan korelasi menunjukkan pola, bukan hubungan sebab-akibat.

## Sumber Data

Badan Pusat Statistik (BPS): TPAK dan TPT Agustus 2022-2024 per kabupaten/kota Sulawesi Selatan, dan kode wilayah BPS. Batas wilayah: geoBoundaries.# tim4-komputasi-statistika-lanjut
