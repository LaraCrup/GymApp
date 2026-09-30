<script setup lang="ts">
definePageMeta({ layout: 'auth' })
useHead({ title: 'Recuperar contraseña' })

const supabase = useSupabaseClient()

const email = ref('')
const error = ref('')
const loading = ref(false)
const sent = ref(false)

async function submit() {
  error.value = ''
  if (!email.value.trim()) {
    error.value = 'Escribí el email con el que entrás a la app.'
    return
  }
  loading.value = true
  // El link del mail lo arma la plantilla (supabase/templates/recovery.html) y lleva a /clave.
  const { error: e } = await supabase.auth.resetPasswordForEmail(email.value.trim())
  loading.value = false
  if (e) {
    error.value = friendlyError(e)
    return
  }
  sent.value = true
}
</script>

<template>
  <template v-if="sent">
    <EmptyState
      icon="check"
      title="Revisá tu mail"
      text="Si ese email tiene cuenta, en unos minutos te llega un mail con un botón para elegir una contraseña nueva. Si no aparece, buscalo en «Correo no deseado» o «Spam»."
    >
      <AppButton variant="secondary" block to="/entrar">Volver a entrar</AppButton>
    </EmptyState>
  </template>

  <template v-else>
    <h1 class="text-3xl font-bold">¿Te olvidaste la contraseña?</h1>
    <p class="mt-2 mb-6 text-muted">Te mandamos un mail para que elijas una nueva.</p>

    <form class="flex flex-col gap-5" novalidate @submit.prevent="submit">
      <AppInput v-model="email" label="Tu email" type="email" autocomplete="email" inputmode="email" />
      <ErrorBox :message="error" />
      <AppButton type="submit" size="lg" block :loading="loading">Mandarme el mail</AppButton>
      <AppButton variant="ghost" block to="/entrar">Volver</AppButton>
    </form>
  </template>
</template>
