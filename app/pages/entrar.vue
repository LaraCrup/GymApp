<script setup lang="ts">
definePageMeta({
  layout: 'auth',
  // Si ya hay sesión, no tiene sentido mostrar el login.
  middleware: () => {
    if (useSupabaseSession().value) return navigateTo('/')
  },
})
useHead({ title: 'Entrar' })

const supabase = useSupabaseClient()
const { adminName } = useAppConfig()

const email = ref('')
const password = ref('')
const error = ref('')
const loading = ref(false)

async function submit() {
  error.value = ''
  if (!email.value.trim() || !password.value) {
    error.value = 'Completá tu email y tu contraseña.'
    return
  }
  loading.value = true
  const { error: e } = await supabase.auth.signInWithPassword({
    email: email.value.trim(),
    password: password.value,
  })
  loading.value = false
  if (e) {
    error.value = friendlyError(e)
    return
  }
  await navigateTo('/')
}
</script>

<template>
  <div class="mb-8 flex flex-col items-center gap-3 text-center">
    <span class="flex size-20 items-center justify-center rounded-full bg-primary text-white">
      <AppIcon name="dumbbell" :size="44" />
    </span>
    <h1 class="text-3xl font-bold">Mis Rutinas</h1>
    <p class="text-muted">Entrá con tu email y tu contraseña.</p>
  </div>

  <form class="flex flex-col gap-5" novalidate @submit.prevent="submit">
    <AppInput v-model="email" label="Email" type="email" autocomplete="email" inputmode="email" />
    <PasswordInput v-model="password" label="Contraseña" autocomplete="current-password" />
    <ErrorBox :message="error" />
    <AppButton type="submit" size="lg" block :loading="loading">Entrar</AppButton>
  </form>

  <div class="mt-6 flex flex-col items-center gap-4 text-center">
    <AppButton variant="ghost" to="/recuperar">Me olvidé la contraseña</AppButton>
    <p class="text-muted">¿No tenés cuenta? Pedile a {{ adminName }} que te invite.</p>
  </div>
</template>
