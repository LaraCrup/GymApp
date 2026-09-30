<script setup lang="ts">
// Carga diferida: hasta que se toca "play" solo se muestra la miniatura (una imagen).
// El iframe de YouTube pesa mucho; así una lista con 20 videos no traba el celular.
const props = defineProps<{ youtubeId: string | null; title: string }>()

const playing = ref(false)
watch(() => props.youtubeId, () => (playing.value = false))
</script>

<template>
  <div class="relative aspect-video w-full overflow-hidden rounded-2xl bg-black ring-1 ring-line">
    <template v-if="youtubeId">
      <iframe
        v-if="playing"
        :src="youtubeEmbedUrl(youtubeId)"
        :title="`Video: ${title}`"
        class="absolute inset-0 size-full"
        allow="autoplay; encrypted-media; picture-in-picture; fullscreen"
        allowfullscreen
      />
      <button
        v-else
        type="button"
        class="group absolute inset-0 flex items-center justify-center"
        :aria-label="`Ver video de ${title}`"
        @click="playing = true"
      >
        <img :src="youtubeThumbnail(youtubeId)" alt="" loading="lazy" decoding="async" class="absolute inset-0 size-full object-cover">
        <span class="relative flex items-center gap-2 glow rounded-full bg-brand px-5 py-3 text-sm font-semibold transition group-active:scale-95">
          <AppIcon name="play" :size="20" />
          Ver video
        </span>
      </button>
    </template>
    <div v-else class="absolute inset-0 flex flex-col items-center justify-center gap-2 bg-brand-soft text-primary">
      <AppIcon name="dumbbell" :size="32" />
      <span class="text-sm font-semibold">Todavía no tiene video</span>
    </div>
  </div>
</template>
