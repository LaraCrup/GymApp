<script setup lang="ts">
useHead({ title: 'Mi cuenta' })

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const isAdmin = useIsAdmin()
const toast = useToast()
const { confirm } = useConfirm()

const loading = ref(false)

async function logout() {
  const ok = await confirm({
    title: '¿Salir de la app?',
    message: 'Para volver a entrar vas a necesitar tu email y tu contraseña.',
    confirmLabel: 'Sí, salir',
  })
  if (!ok) return
  loading.value = true
  // scope local: cierra solo este celular, no los otros dispositivos donde esté abierta.
  const { error } = await supabase.auth.signOut({ scope: 'local' })
  loading.value = false
  if (error) {
    toast.error(friendlyError(error))
    return
  }
  await navigateTo('/entrar')
}
</script>

<template>
  <AppHeader title="Mi cuenta">
    <template #action>
      <DownloadAppLink />
    </template>
  </AppHeader>
  <div class="flex flex-col gap-6 p-4">
    <section class="card flex items-center gap-4 rounded-2xl p-5">
      <span class="glow flex size-12 shrink-0 items-center justify-center rounded-full bg-brand text-lg font-bold uppercase" aria-hidden="true">
        {{ user?.email?.[0] }}
      </span>
      <div class="min-w-0 flex-1">
        <p class="text-sm text-muted">Entraste como</p>
        <p class="text-base font-semibold break-all">{{ user?.email }}</p>
      </div>
      <!-- Solo para quien administra el catálogo de ejercicios. -->
      <span
        v-if="isAdmin"
        class="shrink-0 self-start rounded-lg border border-primary/30 bg-brand-soft px-2.5 py-0.5 text-xs font-semibold text-primary-strong"
        title="Administrás el catálogo de ejercicios"
      >
        Admin
      </span>
    </section>

    <div class="flex flex-col gap-3">
      <AppButton variant="secondary" block to="/clave">Modificar mi contraseña</AppButton>
      <AppButton variant="danger" block :loading="loading" @click="logout">Cerrar sesión</AppButton>
    </div>
  </div>
</template>
