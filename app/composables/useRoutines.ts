import type { Tables, TablesUpdate } from '~/types/database.types'

export type Routine = Tables<'routines'>
export type RoutineSummary = Routine & { exercise_count: number }
export type RoutineItem = Tables<'routine_exercises'> & { exercise: Tables<'exercises'> }
export type RoutineWithItems = Routine & { items: RoutineItem[] }
export type RoutineItemWithRoutine = Tables<'routine_exercises'> & { routine: Pick<Routine, 'id' | 'name'> }
export type ItemSettings = Pick<Tables<'routine_exercises'>, 'sets' | 'reps' | 'seconds' | 'weight_kg'>

/** Rutinas de la persona logueada. RLS en la base garantiza que nadie vea las de otro. */
export function useRoutines() {
  const supabase = useSupabaseClient()

  async function list(): Promise<RoutineSummary[]> {
    const { data, error } = await supabase
      .from('routines')
      .select('*, routine_exercises(count)')
      .order('created_at')
    if (error) throw error
    return data.map(({ routine_exercises, ...r }) => ({ ...r, exercise_count: routine_exercises[0]?.count ?? 0 }))
  }

  async function get(id: string): Promise<RoutineWithItems | null> {
    const { data, error } = await supabase
      .from('routines')
      .select('*, routine_exercises(*, exercise:exercises(*))')
      .eq('id', id)
      .maybeSingle()
    if (error) throw error
    if (!data) return null
    const { routine_exercises, ...routine } = data
    return { ...routine, items: [...routine_exercises].sort((a, b) => a.position - b.position) }
  }

  /** Un ejercicio dentro de una rutina (series, reps o tiempo, y peso), con el nombre de la rutina. */
  async function getItem(routineId: string, exerciseId: string): Promise<RoutineItemWithRoutine | null> {
    const { data, error } = await supabase
      .from('routine_exercises')
      .select('*, routine:routines(id, name)')
      .eq('routine_id', routineId)
      .eq('exercise_id', exerciseId)
      .maybeSingle()
    if (error) throw error
    return data
  }

  async function create(name: string) {
    const { data, error } = await supabase.from('routines').insert({ name: name.trim() }).select().single()
    if (error) throw error
    return data
  }

  async function rename(id: string, name: string) {
    const { error } = await supabase.from('routines').update({ name: name.trim() }).eq('id', id)
    if (error) throw error
  }

  async function remove(id: string) {
    const { error, count } = await supabase.from('routines').delete({ count: 'exact' }).eq('id', id)
    if (error) throw error
    if (!count) throw { code: 'PGRST116' }
  }

  async function addItem(routineId: string, exerciseId: string, settings: ItemSettings): Promise<RoutineItem> {
    const { data, error } = await supabase
      .from('routine_exercises')
      .insert({ routine_id: routineId, exercise_id: exerciseId, ...settings })
      .select('*, exercise:exercises(*)')
      .single()
    if (error) throw error
    return data
  }

  async function updateItem(id: string, patch: TablesUpdate<'routine_exercises'>) {
    const { error } = await supabase.from('routine_exercises').update(patch).eq('id', id)
    if (error) throw error
  }

  async function removeItem(id: string) {
    const { error } = await supabase.from('routine_exercises').delete().eq('id', id)
    if (error) throw error
  }

  async function reorder(routineId: string, ids: string[]) {
    const { error } = await supabase.rpc('reorder_routine_exercises', { p_routine_id: routineId, p_ids: ids })
    if (error) throw error
  }

  return { list, get, getItem, create, rename, remove, addItem, updateItem, removeItem, reorder }
}
