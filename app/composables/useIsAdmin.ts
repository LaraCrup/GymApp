/** true si la persona logueada es admin del catálogo (app_metadata.is_admin, lo marca el dueño en la base). */
export function useIsAdmin() {
  const user = useSupabaseUser()
  return computed(() => user.value?.app_metadata?.is_admin === true)
}
