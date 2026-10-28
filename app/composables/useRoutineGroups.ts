import type { Tables } from '~/types/database.types'

export type RoutineGroup = Tables<'routine_groups'>

/** Grupos ("carpetas") donde cada persona ordena sus rutinas. RLS en la base: cada uno ve los suyos. */
export function useRoutineGroups() {
  const supabase = useSupabaseClient()

  async function list(): Promise<RoutineGroup[]> {
    const { data, error } = await supabase.from('routine_groups').select('*').order('position')
    if (error) throw error
    return data
  }

  async function create(name: string) {
    const { data, error } = await supabase.from('routine_groups').insert({ name: name.trim() }).select().single()
    if (error) throw error
    return data
  }

  async function rename(id: string, name: string) {
    const { error } = await supabase.from('routine_groups').update({ name: name.trim() }).eq('id', id)
    if (error) throw error
  }

  /** Borra el grupo; sus rutinas no se borran, quedan sin grupo (`on delete set null`). */
  async function remove(id: string) {
    const { error, count } = await supabase.from('routine_groups').delete({ count: 'exact' }).eq('id', id)
    if (error) throw error
    if (!count) throw { code: 'PGRST116' }
  }

  async function reorder(ids: string[]) {
    const { error } = await supabase.rpc('reorder_routine_groups', { p_ids: ids })
    if (error) throw error
  }

  return { list, create, rename, remove, reorder }
}
