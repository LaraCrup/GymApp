import tailwindcss from '@tailwindcss/vite'

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },

  // App privada: no necesita SEO. SPA simplifica la auth y la PWA, y se deploya como estático.
  ssr: false,

  modules: ['@nuxtjs/supabase', '@vite-pwa/nuxt'],

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
        { name: 'theme-color', content: '#09090f' },
        { name: 'description', content: 'Tus rutinas del gimnasio, tus pesos y tu progreso.' },
        // iPhone: abrir a pantalla completa cuando se agrega a la pantalla de inicio.
        { name: 'apple-mobile-web-app-capable', content: 'yes' },
        { name: 'apple-mobile-web-app-title', content: 'Mis Rutinas' },
        { name: 'apple-mobile-web-app-status-bar-style', content: 'black-translucent' },
      ],
      link: [
        { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' },
        { rel: 'apple-touch-icon', href: '/apple-touch-icon.png' },
      ],
    },
  },

  // La app es SPA: se pre-genera "/" para que el service worker tenga la página base guardada.
  nitro: {
    prerender: { routes: ['/'] },
  },

  // Instalable en la pantalla de inicio del celular.
  pwa: {
    registerType: 'autoUpdate',
    manifest: {
      name: 'Mis Rutinas',
      short_name: 'Mis Rutinas',
      description: 'Tus rutinas del gimnasio, tus pesos y tu progreso.',
      lang: 'es',
      start_url: '/',
      display: 'standalone',
      orientation: 'portrait',
      background_color: '#09090f',
      theme_color: '#09090f',
      icons: [
        { src: '/pwa-192x192.png', sizes: '192x192', type: 'image/png' },
        { src: '/pwa-512x512.png', sizes: '512x512', type: 'image/png' },
        { src: '/maskable-icon-512x512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
      ],
    },
    workbox: {
      // Cualquier pantalla abre con la app guardada, aunque no haya señal.
      navigateFallback: '/',
      globPatterns: ['**/*.{js,css,html,svg,png,ico,woff2}'],
      // Los datos (Supabase) nunca se guardan: siempre tienen que estar al día.
      // Las miniaturas de YouTube sí, para que las listas carguen rápido.
      runtimeCaching: [
        {
          urlPattern: /^https:\/\/i\.ytimg\.com\/.*/,
          handler: 'CacheFirst',
          options: {
            cacheName: 'miniaturas-youtube',
            expiration: { maxEntries: 200, maxAgeSeconds: 60 * 60 * 24 * 30 },
            cacheableResponse: { statuses: [0, 200] },
          },
        },
      ],
    },
    client: {
      // Guarda en el celular si la persona dijo "Ahora no" al aviso de instalar.
      installPrompt: 'pwa-instalar-descartado',
    },
    devOptions: { enabled: false },
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
