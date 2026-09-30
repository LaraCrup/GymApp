import tailwindcss from '@tailwindcss/vite'

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },

  // App privada: no necesita SEO. SPA simplifica la auth y la PWA, y se deploya como estático.
  ssr: false,

  modules: ['@nuxtjs/supabase'],

  css: ['~/assets/css/main.css'],

  vite: {
    plugins: [tailwindcss()],
  },

  app: {
    head: {
      htmlAttrs: { lang: 'es' },
      title: 'Mis Rutinas',
      meta: [
        { name: 'viewport', content: 'width=device-width, initial-scale=1, viewport-fit=cover' },
        { name: 'theme-color', content: '#1d4ed8' },
      ],
    },
  },

  supabase: {
    // Sesión guardada en el celular (localStorage) y renovada sola: no hay que volver a entrar cada día.
    useSsrCookies: false,
    // Generados desde la base local con `npm run db:types`.
    types: '~/types/database.types.ts',
    redirectOptions: {
      login: '/entrar',
      callback: '/confirmar',
      exclude: ['/clave', '/recuperar'],
    },
  },
})
