import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { effectScope } from 'vue'
import { useAutoSave } from './useAutoSave'

describe('useAutoSave', () => {
  beforeEach(() => vi.useFakeTimers())
  afterEach(() => vi.useRealTimers())

  function setup(save: (v: number) => Promise<void>) {
    const scope = effectScope()
    const api = scope.run(() => useAutoSave(save, 1000))!
    return { ...api, scope }
  }

  it('varios toques seguidos = una sola escritura con el último valor', async () => {
    const save = vi.fn().mockResolvedValue(undefined)
    const { schedule, status } = setup(save)
    schedule(41)
    schedule(42)
    schedule(42.5)
    expect(status.value).toBe('pending')
    expect(save).not.toHaveBeenCalled()
    await vi.advanceTimersByTimeAsync(1000)
    expect(save).toHaveBeenCalledTimes(1)
    expect(save).toHaveBeenCalledWith(42.5)
    expect(status.value).toBe('saved')
  })

  it('si falla, queda en error y el reintento guarda el mismo valor', async () => {
    const save = vi.fn().mockRejectedValueOnce(new TypeError('Failed to fetch')).mockResolvedValue(undefined)
    const { schedule, flush, status } = setup(save)
    schedule(50)
    await vi.advanceTimersByTimeAsync(1000)
    expect(status.value).toBe('error')
    await flush()
    expect(save).toHaveBeenLastCalledWith(50)
    expect(status.value).toBe('saved')
  })

  it('un cambio durante el guardado se guarda después, sin pisarse', async () => {
    let resolveFirst!: () => void
    const save = vi.fn()
      .mockImplementationOnce(() => new Promise<void>(r => (resolveFirst = r)))
      .mockResolvedValue(undefined)
    const { schedule, status } = setup(save)
    schedule(10)
    await vi.advanceTimersByTimeAsync(1000)
    expect(status.value).toBe('saving')
    schedule(12.5)
    await vi.advanceTimersByTimeAsync(1000)
    resolveFirst()
    await vi.advanceTimersByTimeAsync(0)
    expect(save).toHaveBeenNthCalledWith(2, 12.5)
    expect(status.value).toBe('saved')
  })

  it('al salir de la pantalla guarda lo pendiente', async () => {
    const save = vi.fn().mockResolvedValue(undefined)
    const { schedule, scope } = setup(save)
    schedule(30)
    scope.stop()
    await vi.advanceTimersByTimeAsync(0)
    expect(save).toHaveBeenCalledWith(30)
  })
})
