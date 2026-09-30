interface ErrorLike {
  code?: string
  name?: string
  status?: number
  message?: string
}

// Códigos de error de Supabase Auth → explicación en criollo.
const byCode: Record<string, string> = {
  invalid_credentials: 'El email o la contraseña no coinciden. Revisalos y probá de nuevo.',
  email_not_confirmed: 'Todavía no activaste tu cuenta. Buscá el mail de invitación y tocá «Activar mi cuenta».',
  user_banned: 'Tu cuenta está pausada. Hablá con quien te invitó.',
  weak_password: 'La contraseña es muy corta: tiene que tener al menos 8 letras o números.',
  same_password: 'Es la misma contraseña que ya tenías. Elegí una distinta.',
  otp_expired: 'Este link ya se usó o venció.',
  over_request_rate_limit: 'Hubo muchos intentos seguidos. Esperá unos minutos y probá de nuevo.',
  over_email_send_rate_limit: 'Ya te mandamos un mail hace poco. Esperá unos minutos antes de pedir otro.',
  signup_disabled: 'No se pueden crear cuentas desde la app. Pedí que te inviten.',

  // Base de datos (Postgres / PostgREST)
  '23505': 'Ya existe uno con ese nombre. Buscalo en la lista.',
  '23503': 'No se puede borrar porque alguien lo usa en una rutina o tiene historial de pesos.',
  '23514': 'Algún dato no es válido. Revisalo y probá de nuevo.',
  '42501': 'No tenés permiso para hacer esto.',
  PGRST116: 'No lo encontramos. Puede que lo hayan borrado.',
}

export const NETWORK_ERROR = 'No hay conexión a internet. Revisá el wifi o los datos y probá de nuevo.'
export const GENERIC_ERROR = 'Algo salió mal. Probá de nuevo en un ratito.'

function isNetworkError(e: ErrorLike) {
  if (e.name === 'AuthRetryableFetchError' || e.status === 0) return true
  // Chrome: "Failed to fetch" · Safari: "Load failed" · Firefox: "NetworkError…"
  return /failed to fetch|load failed|networkerror/i.test(e.message ?? '')
}

/** Traduce cualquier error (de Supabase o de red) a un mensaje que se entienda sin saber de computadoras. */
export function friendlyError(error: unknown): string {
  if (!error || typeof error !== 'object') return GENERIC_ERROR
  const e = error as ErrorLike
  if (isNetworkError(e)) return NETWORK_ERROR
  if (e.code && byCode[e.code]) return byCode[e.code]!
  return GENERIC_ERROR
}
