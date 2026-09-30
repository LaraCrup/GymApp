<template>
  <!-- Enlaza el manifest de la PWA: sin esto el celular no ofrece instalar la app. -->
  <NuxtPwaManifest />
  <NuxtRouteAnnouncer />
  <NuxtLayout>
    <NuxtPage />
  </NuxtLayout>
  <ToastHost />
  <ConfirmDialog />
</template>
