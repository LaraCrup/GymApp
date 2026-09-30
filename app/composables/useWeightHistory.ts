export interface WeightPoint {
  logged_on: string
  weight_kg: number
}

/** Historial de pesos de la persona logueada (lo escribe la base; acá solo se lee). */
export function useWeightHistory() {
  const supabase = useSupabaseClient()

  async function forExercise(exerciseId: string): Promise<WeightPoint[]> {
    const { data, error } = await supabase
      .from('weight_logs')
      .select('logged_on, weight_kg')
      .eq('exercise_id', exerciseId)
      .order('logged_on')
    if (error) throw error
    return data
  }

  /** El último peso de días anteriores, por ejercicio ("La vez anterior: 35 kg"). */
  async function previous(exerciseIds: string[]): Promise<Map<string, WeightPoint>> {
    if (!exerciseIds.length) return new Map()
    const { data, error } = await supabase.rpc('previous_weights', { p_exercise_ids: exerciseIds })
    if (error) throw error
    return new Map(data.map(p => [p.exercise_id, { logged_on: p.logged_on, weight_kg: p.weight_kg }]))
  }

  return { forExercise, previous }
}
