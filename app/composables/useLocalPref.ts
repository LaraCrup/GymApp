/**
 * Preferencia chica que se recuerda en este celular (ej: "agrupar por músculo").
 * Si el navegador no deja guardar (modo privado), funciona igual durante la visita.
 */
export function useLocalPref<T>(key: string, fallback: T) {
  const value = ref(fallback) as Ref<T>

  try {
    const stored = localStorage.getItem(key)
    if (stored !== null) value.value = JSON.parse(stored) as T
  }
  catch {
    // Sin acceso a localStorage: nos quedamos con el valor por defecto.
  }

  watch(value, v => {
    try {
      localStorage.setItem(key, JSON.stringify(v))
    }
    catch {
      // Idem: no se recuerda, pero la app sigue andando.
    }
  })

  return value
}
