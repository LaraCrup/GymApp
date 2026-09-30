<script setup lang="ts">
// Elegir contraseña. Se llega de tres formas:
//  - link de invitación   → /clave?token_hash=…&type=invite
//  - link de recuperación → /clave?token_hash=…&type=recovery
//  - desde "Mi cuenta", con sesión iniciada y sin token
definePageMeta({ layout: 'auth' })
useHead({ title: 'Elegir contraseña' })

const MIN_LENGTH = 8

const supabase = useSupabaseClient()
const session = useSupabaseSession()
const toast = useToast()
const { adminName } = useAppConfig()
const route = useRoute()

const tokenHash = typeof route.query.token_hash === 'string' ? route.query.token_hash : ''
const type = route.query.type === 'invite' ? 'invite' : 'recovery'
const isInvite = type === 'invite'

// Con token, primero se pide un toque: los antivirus del mail abren los links solos y
// si verificáramos al cargar la página, la invitación quedaría gastada antes de que la persona la vea.
type Step = 'activate' | 'form' | 'invalid'
const step = ref<Step>(tokenHash ? 'activate' : session.value ? 'form' : 'invalid')

const password = ref('')
const error = ref('')
const loading = ref(false)

async function activate() {
  error.value = ''
  loading.value = true
  const { error: e } = await supabase.auth.verifyOtp({ token_hash: tokenHash, type })
  loading.value = false
  if (e) {
    if (e.code === 'otp_expired' || e.status === 403) step.value = 'invalid'
    else error.value = friendlyError(e)
    return
  }
  step.value = 'form'
}

async function save() {
  error.value = ''
  if (password.value.length < MIN_LENGTH) {
    error.value = `La contraseña tiene que tener al menos ${MIN_LENGTH} letras o números.`
    return
  }
  loading.value = true
  const { error: e } = await supabase.auth.updateUser({ password: password.value })
  loading.value = false
  if (e) {
    error.value = friendlyError(e)
    return
  }
  toast.ok(isInvite ? '¡Listo! Ya podés usar la app' : 'Contraseña guardada')
  await navigateTo('/')
}
</script>

<template>
  <!-- 1. Activar el link -->
  <template v-if="step === 'activate'">
    <h1 class="text-3xl font-bold">{{ isInvite ? '¡Hola! 👋' : 'Cambiar contraseña' }}</h1>
    <p class="mt-2 mb-6 text-muted">
      {{ isInvite
        ? 'Te invitaron a Mis Rutinas. Tocá el botón para activar tu cuenta.'
        : 'Tocá el botón para elegir tu contraseña nueva.' }}
    </p>
    <div class="flex flex-col gap-5">
      <ErrorBox :message="error" />
      <AppButton size="lg" block :loading="loading" @click="activate">
        {{ isInvite ? 'Activar mi cuenta' : 'Continuar' }}
      </AppButton>
    </div>
  </template>

  <!-- 2. Elegir la contraseña -->
  <template v-else-if="step === 'form'">
    <h1 class="text-3xl font-bold">Elegí tu contraseña</h1>
    <p class="mt-2 mb-6 text-muted">
      La vas a usar para entrar a la app junto con tu email. Anotala en un lugar seguro.
    </p>
    <form class="flex flex-col gap-5" novalidate @submit.prevent="save">
      <PasswordInput
        v-model="password"
        label="Contraseña nueva"
        autocomplete="new-password"
        :hint="`Mínimo ${MIN_LENGTH} letras o números.`"
      />
      <ErrorBox :message="error" />
      <AppButton type="submit" size="lg" block :loading="loading">Guardar contraseña</AppButton>
      <AppButton v-if="!tokenHash" variant="ghost" block to="/cuenta">Cancelar</AppButton>
    </form>
  </template>

  <!-- 3. Link usado o vencido -->
  <EmptyState
    v-else
    icon="alert"
    title="Este link ya no sirve"
    :text="isInvite
      ? `Ya se usó o venció. Pedile a ${adminName} que te mande una invitación nueva.`
      : 'Ya se usó o venció. Podés pedir otro mail para cambiar la contraseña.'"
  >
    <div class="flex flex-col gap-3">
      <AppButton v-if="!isInvite" block to="/recuperar">Pedir otro mail</AppButton>
      <AppButton variant="secondary" block to="/entrar">Ir a entrar</AppButton>
    </div>
  </EmptyState>
</template>
