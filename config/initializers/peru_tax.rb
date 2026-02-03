module PeruTax
  IGV_RATE = 0.18 # 18%

  # Extrae el IGV de un monto que ya lo incluye
  def self.extract_igv(total_with_igv)
    (total_with_igv - base_amount(total_with_igv)).round(2)
  end

  # Obtiene la base imponible (sin IGV) de un monto que ya lo incluye
  def self.base_amount(total_with_igv)
    (total_with_igv / (1 + IGV_RATE)).round(2)
  end
end
