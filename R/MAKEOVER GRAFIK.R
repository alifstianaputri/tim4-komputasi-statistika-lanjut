
# ==========================================================
# MAKEOVER GRAFIK PREVALENSI KETIDAKCUKUPAN KONSUMSI PANGAN
# SULAWESI SELATAN DAN INDONESIA, 2017-2023
# ==========================================================

# Memanggil package
library(ggplot2)


# ==========================================================
# 1. MEMASUKKAN DATA
# ==========================================================

data <- data.frame(
  Tahun = 2017:2023,
  
  Sulawesi_Selatan = c(
    5.43, 6.22, 7.65, 10.14,
    7.93, 10.79, 7.84
  ),
  
  Indonesia = c(
    8.23, 7.92, 7.63, 8.34,
    8.49, 10.21, 8.53
  )
)


# Melihat data
print(data)


# ==========================================================
# 2. MEMBUAT GRAFIK MAKEOVER
# ==========================================================

ggplot(data, aes(x = Tahun)) +
  
  # --------------------------------------------------------
# GARIS SULAWESI SELATAN
# --------------------------------------------------------

geom_line(
  aes(
    y = Sulawesi_Selatan,
    color = "Sulawesi Selatan"
  ),
  linewidth = 1.3
) +
  
  # Titik Sulawesi Selatan
  geom_point(
    aes(
      y = Sulawesi_Selatan,
      color = "Sulawesi Selatan"
    ),
    size = 3
  ) +
  
  # Label nilai Sulawesi Selatan
  geom_text(
    aes(
      y = Sulawesi_Selatan,
      label = sprintf("%.2f", Sulawesi_Selatan)
    ),
    color = "#1F77B4",
    vjust = -0.8,
    size = 3.5
  ) +
  
  
  # --------------------------------------------------------
# GARIS INDONESIA
# --------------------------------------------------------

geom_line(
  aes(
    y = Indonesia,
    color = "Indonesia"
  ),
  linewidth = 1.1
) +
  
  # Titik Indonesia
  geom_point(
    aes(
      y = Indonesia,
      color = "Indonesia"
    ),
    size = 3
  ) +
  
  # Label nilai Indonesia
  geom_text(
    aes(
      y = Indonesia,
      label = sprintf("%.2f", Indonesia)
    ),
    color = "#7F7F7F",
    vjust = 1.8,
    size = 3.5
  ) +
  
  
  # ========================================================
# 3. MEMBERIKAN ANOTASI PADA NILAI TERTINGGI
# ========================================================

annotate(
  "text",
  x = 2022,
  y = 10.79,
  label = "Tertinggi Sulawesi Selatan\n10,79%",
  hjust = -0.05,
  vjust = -0.3,
  size = 3.5,
  fontface = "bold",
  color = "#1F77B4"
) +
  
  
  # ========================================================
# 4. JUDUL DAN LABEL
# ========================================================

labs(
  title = "Prevalensi Ketidakcukupan Konsumsi Pangan",
  subtitle = "Sulawesi Selatan dan Indonesia, 2017–2023",
  
  x = "Tahun",
  
  y = "Prevalensi (%)",
  
  color = "Wilayah",
  
  caption = "Sumber: Badan Pusat Statistik"
) +
  
  
  # ========================================================
# 5. PENGATURAN SUMBU X
# ========================================================

scale_x_continuous(
  breaks = 2017:2023
) +
  
  
  # ========================================================
# 6. PENGATURAN SUMBU Y
# ========================================================

scale_y_continuous(
  limits = c(0, 12),
  breaks = seq(0, 12, 2)
) +
  
  
  # ========================================================
# 7. WARNA
# ========================================================

scale_color_manual(
  values = c(
    "Sulawesi Selatan" = "#1F77B4",
    "Indonesia" = "#7F7F7F"
  )
) +
  
  
  # ========================================================
# 8. TEMA GRAFIK
# ========================================================

theme_minimal(base_size = 12) +
  
  theme(
    
    # Judul
    plot.title = element_text(
      face = "bold",
      size = 17
    ),
    
    # Subtitle
    plot.subtitle = element_text(
      size = 12
    ),
    
    # Label sumbu
    axis.title = element_text(
      face = "bold"
    ),
    
    # Legenda
    legend.position = "top",
    
    legend.title = element_text(
      face = "bold"
    ),
    
    # Hilangkan grid minor
    panel.grid.minor = element_blank(),
    
    # Sumber
    plot.caption = element_text(
      hjust = 0,
      size = 9
    )
  )

