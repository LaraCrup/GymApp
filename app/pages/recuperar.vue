<script setup lang="ts">
definePageMeta({ layout: 'auth' })
useHead({ title: 'Recuperar contraseña' })

const supabase = useSupabaseClient()
const route = useRoute()
const { adminName } = useAppConfig()

// Viene cargado desde "Entrar" si ya lo había escrito ahí.
const email = ref(typeof route.query.email === 'string' ? route.query.email : '')
const error = ref('')
const loading = ref(false)
const sentTo = ref('')

// Supabase responde "ok" aunque el email no tenga cuenta (para no revelar quién usa la app),
// así que la pantalla de "enviado" muestra a qué dirección fue: un error de tipeo salta a la vista.
const WAIT = 60
const secondsLeft = ref(0)
let timer: ReturnType<typeof setInterval> | undefined
onBeforeUnmount(() => clearInterval(timer))

function startWait() {
  secondsLeft.value = WAIT
  clearInterval(timer)
  timer = setInterval(() => {
    if (--secondsLeft.value <= 0) clearInterval(timer)
  }, 1000)
}

async function send() {
  error.value = ''
  const address = email.value.trim().toLowerCase()
  if (!address) {
    error.value = 'Escribí el email con el que entrás a la app.'
    return
  }
  loading.value = true
  // El link del mail lo arma la plantilla (supabase/templates/recovery.html) y lleva a /clave.
  const { error: e } = await supabase.auth.resetPasswordForEmail(address)
  loading.value = false
  if (e) {
    error.value = friendlyError(e)
    return
  }
  sentTo.value = address
  startWait()
}

function editEmail() {
  sentTo.value = ''
  error.value = ''
}
</script>

<template>
  <template v-if="sentTo">
    <EmptyState icon="check" title="Revisá tu mail">
      <div class="flex flex-col gap-4 text-left text-sm">
        <p class="text-center text-muted">
          Si hay una cuenta con este email, te llega un mail con un botón para elegir una contraseña nueva:
        </p>
        <p class="rounded-xl bg-white p-3 text-center text-base font-semibold break-all">{{ sentTo }}</p>
        <ul class="flex list-disc flex-col gap-1 pl-5 text-muted">
          <li>Puede tardar unos minutos.</li>
          <li>Buscalo también en «Correo no deseado», «Spam» o «Promociones».</li>
          <li>Tiene que ser el mismo email con el que te invitaron. Si no te acordás cuál es, preguntale a {{ adminName }}.</li>
        </ul>
        <ErrorBox :message="error" />
        <div class="flex flex-col gap-3">
          <AppButton variant="secondary" block :loading="loading" :disabled="secondsLeft > 0" @click="send">
            {{ secondsLeft > 0 ? `Mandar de nuevo (en ${secondsLeft} s)` : 'Mandar de nuevo' }}
          </AppButton>
          <AppButton variant="ghost" block @click="editEmail">Corregir el email</AppButton>
          <AppButton variant="ghost" block to="/entrar">Volver a entrar</AppButton>
        </div>
      </div>
    </EmptyState>
  </template>

  <template v-else>
    <h1 class="text-xl font-bold">¿Te olvidaste la contraseña?</h1>
    <p class="mt-1 mb-6 text-sm text-muted">Te mandamos un mail para que elijas una nueva.</p>

    <form class="flex flex-col gap-5" novalidate @submit.prevent="send">
      <AppInput v-model="email" label="Tu email" type="email" autocomplete="email" inputmode="email" enterkeyhint="send" />
      <ErrorBox :message="error" />
      <AppButton type="submit" size="lg" block :loading="loading">Mandarme el mail</AppButton>
      <AppButton variant="ghost" block to="/entrar">Volver</AppButton>
    </form>
  </template>
</template>
