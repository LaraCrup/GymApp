import type { Exercise, ExerciseInput } from '~/composables/useCatalog'
import { parseYouTubeId } from './youtube'

/** Lo que se escribe en el formulario, tal cual (texto libre). */
export interface ExerciseDraft {
  name: string
  /** Alias separados por coma: "Remo inclinado, Bent over row". */
  aliasesText: string
  muscleGroupId: string
  youtubeUrl: string
}

export type DraftErrors = Partial<Record<'name' | 'muscleGroupId' | 'youtubeUrl', string>>

export function emptyDraft(name = ''): ExerciseDraft {
  return { name, aliasesText: '', muscleGroupId: '', youtubeUrl: '' }
}

export function draftFromExercise(e: Pick<Exercise, 'name' | 'aliases' | 'muscle_group_id' | 'youtube_id'>): ExerciseDraft {
  return {
    name: e.name,
    aliasesText: e.aliases.join(', '),
    muscleGroupId: e.muscle_group_id,
    youtubeUrl: e.youtube_id ? `https://youtu.be/${e.youtube_id}` : '',
  }
}

export function splitAliases(text: string): string[] {
  return text.split(/[,;\n]/).map(a => a.trim()).filter(Boolean)
}

export function validateDraft(d: ExerciseDraft): DraftErrors {
  const errors: DraftErrors = {}
  if (d.name.trim().length < 2) errors.name = 'Escribí el nombre del ejercicio.'
  if (!d.muscleGroupId) errors.muscleGroupId = 'Elegí qué músculo trabaja.'
  if (d.youtubeUrl.trim() && !parseYouTubeId(d.youtubeUrl)) {
    errors.youtubeUrl = 'Ese link no es de un video de YouTube. Copialo desde el botón «Compartir» del video.'
  }
  return errors
}

export function draftToInput(d: ExerciseDraft): ExerciseInput {
  return {
    name: d.name.trim(),
    aliases: splitAliases(d.aliasesText),
    muscle_group_id: d.muscleGroupId,
    youtube_id: parseYouTubeId(d.youtubeUrl),
  }
}
