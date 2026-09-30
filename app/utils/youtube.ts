const VIDEO_ID = /^[A-Za-z0-9_-]{11}$/

/**
 * Saca el ID de 11 caracteres de cualquier link de YouTube (o de un ID pegado solo).
 * Acepta: watch?v=, youtu.be/, shorts/, embed/, live/, con o sin www/m./music., con parámetros extra.
 * Devuelve null si no es un video de YouTube.
 */
export function parseYouTubeId(input: string): string | null {
  const raw = input.trim()
  if (!raw) return null
  if (VIDEO_ID.test(raw)) return raw

  let url: URL
  try {
    url = new URL(/^https?:\/\//i.test(raw) ? raw : `https://${raw}`)
  }
  catch {
    return null
  }

  const host = url.hostname.toLowerCase().replace(/^(www|m|music)\./, '')
  const [first, second] = url.pathname.split('/').filter(Boolean)
  let candidate: string | null | undefined

  if (host === 'youtu.be') candidate = first
  else if (host === 'youtube.com' || host === 'youtube-nocookie.com') {
    if (first === 'watch') candidate = url.searchParams.get('v')
    else if (first && ['shorts', 'embed', 'live', 'v'].includes(first)) candidate = second
  }

  return candidate && VIDEO_ID.test(candidate) ? candidate : null
}

export function youtubeThumbnail(id: string) {
  return `https://i.ytimg.com/vi/${id}/hqdefault.jpg`
}

/** Embed sin cookies de seguimiento; `playsinline` evita que iPhone lo abra en pantalla completa. */
export function youtubeEmbedUrl(id: string) {
  return `https://www.youtube-nocookie.com/embed/${id}?autoplay=1&rel=0&playsinline=1`
}
