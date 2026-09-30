import { describe, expect, it } from 'vitest'
import { draftFromExercise, draftToInput, emptyDraft, splitAliases, validateDraft } from './exerciseDraft'

const ID = 'AbCdEfGh_-1'

describe('splitAliases', () => {
  it('separa por coma, punto y coma o renglón y limpia espacios', () => {
    expect(splitAliases(' Remo inclinado,Bent over row ; Serrucho\nOtro ,, ')).toEqual(['Remo inclinado', 'Bent over row', 'Serrucho', 'Otro'])
  })
})

describe('validateDraft', () => {
  it('pide nombre y grupo muscular', () => {
    const errors = validateDraft(emptyDraft())
    expect(errors.name).toBeTruthy()
    expect(errors.muscleGroupId).toBeTruthy()
  })

  it('el video es opcional, pero si hay link tiene que ser de YouTube', () => {
    const ok = { ...emptyDraft('Remo'), muscleGroupId: 'espalda' }
    expect(validateDraft(ok)).toEqual({})
    expect(validateDraft({ ...ok, youtubeUrl: 'https://vimeo.com/1' }).youtubeUrl).toMatch(/YouTube/)
    expect(validateDraft({ ...ok, youtubeUrl: `https://youtu.be/${ID}` })).toEqual({})
  })
})

describe('draftToInput / draftFromExercise', () => {
  it('convierte el formulario en lo que se guarda', () => {
    expect(draftToInput({ name: ' Remo ', aliasesText: 'A, B', muscleGroupId: 'espalda', youtubeUrl: `https://www.youtube.com/shorts/${ID}` }))
      .toEqual({ name: 'Remo', aliases: ['A', 'B'], muscle_group_id: 'espalda', youtube_id: ID })
  })

  it('ida y vuelta conserva los datos', () => {
    const e = { name: 'Remo', aliases: ['A', 'B'], muscle_group_id: 'espalda', youtube_id: ID }
    expect(draftToInput(draftFromExercise(e))).toEqual(e)
    expect(draftToInput(draftFromExercise({ ...e, youtube_id: null })).youtube_id).toBeNull()
  })
})
