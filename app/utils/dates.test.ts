import { describe, expect, it } from 'vitest'
import { formatShortDate, isoToDay } from './dates'

describe('formatShortDate', () => {
  const now = new Date(2026, 8, 30)

  it('muestra día y mes abreviado del año actual', () => {
    expect(formatShortDate('2026-09-12', now)).toBe('12 sep')
    expect(formatShortDate('2026-01-01', now)).toBe('1 ene')
  })

  it('agrega el año si es de otro año', () => {
    expect(formatShortDate('2025-12-31', now)).toBe('31 dic 2025')
  })
})

describe('isoToDay', () => {
  it('cuenta días exactos sin corrimientos de zona horaria', () => {
    expect(isoToDay('2026-09-13') - isoToDay('2026-09-12')).toBe(1)
    expect(isoToDay('2026-03-01') - isoToDay('2026-02-28')).toBe(1)
  })
})
