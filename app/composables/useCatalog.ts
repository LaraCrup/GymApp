import type { Tables } from '~/types/database.types'

export type Exercise = Tables<'exercises'>
export type MuscleGroup = Tables<'muscle_groups'>

export interface ExerciseInput {
  name: string
  aliases: string[]
  muscle_group_id: string
  youtube_id: string | null
}

/** Grupos musculares: lista fija, se pide una vez y queda en memoria. */
export function useMuscleGroups() {
  const supabase = useSupabaseClient()
  const groups = useState<MuscleGroup[]>('muscle-groups', () => [])

  async function load() {
    if (groups.value.length) return
    const { data, error } = await supabase.from('muscle_groups').select('*').order('sort_order')
    if (error) throw error
    groups.value = data
  }

  function nameOf(id: string) {
    return groups.value.find(g => g.id === id)?.name ?? ''
  }

  return { groups, load, nameOf }
}

/** Lectura y escritura del catálogo compartido. Los permisos los pone RLS en la base. */
export function useCatalog() {
  const supabase = useSupabaseClient()

  async function search(q: string, groupId: string | null) {
    const { data, error } = await supabase.rpc('search_exercises', { q, group_id: groupId ?? undefined })
    if (error) throw error
    return data
  }

  async function get(id: string) {
    const { data, error } = await supabase.from('exercises').select('*').eq('id', id).maybeSingle()
    if (error) throw error
    return data
  }

  async function similar(name: string, aliases: string[]) {
    const { data, error } = await supabase.rpc('similar_exercises', { name, aliases })
    if (error) throw error
    return data
  }

  async function create(input: ExerciseInput) {
    const { data, error } = await supabase.from('exercises').insert(input).select().single()
    if (error) throw error
    return data
  }

  // Si RLS no deja editar/borrar, la base no da error: simplemente no toca ninguna fila.
  async function update(id: string, input: ExerciseInput) {
    const { data, error } = await supabase.from('exercises').update(input).eq('id', id).select()
    if (error) throw error
    if (!data.length) throw { code: '42501' }
    return data[0]!
  }

  async function remove(id: string) {
    const { error, count } = await supabase.from('exercises').delete({ count: 'exact' }).eq('id', id)
    if (error) throw error
    if (!count) throw { code: '42501' }
  }

  return { search, get, similar, create, update, remove }
}
