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
  <AppHeader title="Mi cuenta" />
  <div class="flex flex-col gap-6 p-4">
    <section class="rounded-2xl bg-white p-5">
      <p class="text-muted">Entraste como</p>
      <p class="mt-1 text-xl font-semibold break-all">{{ user?.email }}</p>
      <p v-if="isAdmin" class="mt-3 inline-block rounded-lg bg-primary-soft px-3 py-1 font-semibold text-primary-strong">
        Administrás el catálogo de ejercicios
      </p>
    </section>

    <div class="flex flex-col gap-3">
      <AppButton variant="secondary" block to="/clave">Cambiar mi contraseña</AppButton>
      <AppButton variant="danger" block :loading="loading" @click="logout">Salir de la app</AppButton>
    </div>
  </div>
</template>
