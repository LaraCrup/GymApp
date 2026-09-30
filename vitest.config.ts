import { defineConfig } from 'vitest/config'

// Tests unitarios de funciones puras (app/utils). No levantan Nuxt.
export default defineConfig({
  test: {
    include: ['app/**/*.test.ts'],
  },
})
