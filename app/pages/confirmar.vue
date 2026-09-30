<script setup lang="ts">
// Ruta de "callback" que exige @nuxtjs/supabase. La app no usa logins externos
// (Google, etc.), así que solo redirige al inicio.
definePageMeta({ layout: 'auth', middleware: () => navigateTo('/', { replace: true }) })
</script>

<template>
  <div />
</template>
