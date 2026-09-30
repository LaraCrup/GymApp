import { describe, expect, it } from 'vitest'
import { friendlyError, GENERIC_ERROR, NETWORK_ERROR } from './friendlyError'

describe('friendlyError', () => {
  it('traduce credenciales inválidas', () => {
    expect(friendlyError({ code: 'invalid_credentials', status: 400 })).toMatch(/no coinciden/)
  })

  it('detecta errores de red de cada navegador', () => {
    expect(friendlyError({ name: 'AuthRetryableFetchError', status: 0 })).toBe(NETWORK_ERROR)
    expect(friendlyError(new TypeError('Failed to fetch'))).toBe(NETWORK_ERROR)
    expect(friendlyError(new TypeError('Load failed'))).toBe(NETWORK_ERROR)
    expect(friendlyError(new TypeError('NetworkError when attempting to fetch resource.'))).toBe(NETWORK_ERROR)
  })

  it('traduce errores de la base', () => {
    expect(friendlyError({ code: '23505', message: 'duplicate key value violates unique constraint' })).toMatch(/Ya existe/)
    expect(friendlyError({ code: '42501', message: 'new row violates row-level security policy' })).toMatch(/permiso/)
    expect(friendlyError({ code: '23503' })).toMatch(/rutina/)
  })

  it('detecta errores de red que devuelve supabase-js en consultas', () => {
    expect(friendlyError({ code: '', message: 'TypeError: Failed to fetch' })).toBe(NETWORK_ERROR)
  })

  it('usa un mensaje genérico para lo desconocido', () => {
    expect(friendlyError({ code: 'algo_raro' })).toBe(GENERIC_ERROR)
    expect(friendlyError(null)).toBe(GENERIC_ERROR)
    expect(friendlyError('texto')).toBe(GENERIC_ERROR)
  })

  it('nunca muestra el mensaje técnico original', () => {
    expect(friendlyError({ message: 'JWT expired', code: 'bad_jwt' })).not.toMatch(/JWT/)
  })
})
