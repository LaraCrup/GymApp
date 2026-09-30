import { describe, expect, it } from 'vitest'
import { parseYouTubeId, youtubeEmbedUrl } from './youtube'

// ID con formato válido, armado para el test (no es un video real).
const ID = 'AbCdEfGh_-1'

describe('parseYouTubeId', () => {
  it.each([
    [`https://www.youtube.com/watch?v=${ID}`],
    [`https://youtube.com/watch?v=${ID}&t=42s`],
    [`https://m.youtube.com/watch?feature=share&v=${ID}`],
    [`https://music.youtube.com/watch?v=${ID}&list=RDxyz`],
    [`https://youtu.be/${ID}`],
    [`https://youtu.be/${ID}?si=abc123&t=10`],
    [`https://www.youtube.com/shorts/${ID}`],
    [`https://youtube.com/shorts/${ID}?feature=share`],
    [`https://www.youtube.com/embed/${ID}`],
    [`https://www.youtube-nocookie.com/embed/${ID}?rel=0`],
    [`https://www.youtube.com/live/${ID}`],
    [`youtube.com/watch?v=${ID}`],
    [`youtu.be/${ID}`],
    [`  https://youtu.be/${ID}  `],
    [ID],
  ])('reconoce %s', (input) => {
    expect(parseYouTubeId(input)).toBe(ID)
  })

  it.each([
    [''],
    ['hola'],
    ['https://vimeo.com/123456789'],
    ['https://www.youtube.com/'],
    ['https://www.youtube.com/channel/UCabcdefghijk'],
    ['https://www.youtube.com/watch?v=corto'],
    ['https://youtu.be/'],
    ['https://notyoutube.com/watch?v=' + ID],
  ])('rechaza %s', (input) => {
    expect(parseYouTubeId(input)).toBeNull()
  })
})

describe('youtubeEmbedUrl', () => {
  it('usa youtube-nocookie', () => {
    expect(youtubeEmbedUrl(ID)).toMatch(/^https:\/\/www\.youtube-nocookie\.com\/embed\/AbCdEfGh_-1\?/)
  })
})
