const MONTHS = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic']

// Las fechas del historial vienen como 'YYYY-MM-DD' (fecha de Argentina, sin hora).
// Se leen por partes para que la zona horaria del celular no las corra un día.
function parts(iso: string) {
  const [y, m, d] = iso.split('-').map(Number) as [number, number, number]
  return { y, m, d }
}

/** '2026-09-12' → '12 sep' (o '12 sep 2025' si es de otro año). */
export function formatShortDate(iso: string, now = new Date()) {
  const { y, m, d } = parts(iso)
  const base = `${d} ${MONTHS[m - 1]}`
  return y === now.getFullYear() ? base : `${base} ${y}`
}

/** Para ubicar fechas en el eje del gráfico. */
export function isoToDay(iso: string) {
  const { y, m, d } = parts(iso)
  return Date.UTC(y, m - 1, d) / 86_400_000
}
