const kgFormat = new Intl.NumberFormat('es-AR', { maximumFractionDigits: 2 })

/** 37.5 → "37,5" (formato argentino, sin ceros de más). */
export function formatNumber(n: number) {
  return kgFormat.format(n)
}

/** 37.5 → "37,5 kg" */
export function formatKg(n: number) {
  return `${formatNumber(n)} kg`
}

/** Lee lo que se escribe a mano: acepta coma o punto. "37,5" → 37.5. Vacío o inválido → null. */
export function parseNumber(text: string): number | null {
  const clean = text.trim().replace(/\s|kg/gi, '').replace(',', '.')
  if (!/^\d+(\.\d+)?$/.test(clean)) return null
  return Number(clean)
}

/** Limita a [min, max] y redondea a 2 decimales (lo que guarda la base). */
export function clampNumber(n: number, min: number, max: number) {
  return Math.round(Math.min(max, Math.max(min, n)) * 100) / 100
}

/** Duración de una serie: 40 → "40 seg", 60 → "1 min", 90 → "1:30 min". */
export function formatSeconds(s: number) {
  if (s < 60) return `${s} seg`
  const min = Math.floor(s / 60)
  const rest = s % 60
  return rest ? `${min}:${String(rest).padStart(2, '0')} min` : `${min} min`
}
