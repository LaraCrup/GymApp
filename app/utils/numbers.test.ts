import { describe, expect, it } from 'vitest'
import { clampNumber, formatKg, parseNumber } from './numbers'

describe('formatKg', () => {
  it('usa coma decimal y no muestra ceros de más', () => {
    expect(formatKg(37.5)).toBe('37,5 kg')
    expect(formatKg(40)).toBe('40 kg')
    expect(formatKg(12.25)).toBe('12,25 kg')
    expect(formatKg(0)).toBe('0 kg')
  })
})

describe('parseNumber', () => {
  it.each([
    ['37,5', 37.5],
    ['37.5', 37.5],
    [' 40 ', 40],
    ['40kg', 40],
    ['40 kg', 40],
    ['0', 0],
  ])('lee %s', (text, expected) => {
    expect(parseNumber(text)).toBe(expected)
  })

  it.each([[''], ['abc'], ['-5'], ['3,5,5'], ['1e3']])('rechaza %s', (text) => {
    expect(parseNumber(text)).toBeNull()
  })
})

describe('clampNumber', () => {
  it('limita y redondea a 2 decimales', () => {
    expect(clampNumber(-2.5, 0, 999)).toBe(0)
    expect(clampNumber(1200, 0, 999)).toBe(999)
    expect(clampNumber(0.1 + 0.2, 0, 999)).toBe(0.3)
  })
})
