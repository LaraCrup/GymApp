<script setup lang="ts">
// Miniatura liviana: solo una imagen con carga diferida, nunca un iframe.
defineProps<{ youtubeId: string | null }>()
</script>

<template>
  <span class="relative flex h-14 w-20 shrink-0 items-center justify-center overflow-hidden rounded-lg bg-primary-soft text-primary">
    <template v-if="youtubeId">
      <img :src="youtubeThumbnail(youtubeId)" alt="" loading="lazy" decoding="async" class="size-full object-cover">
      <span class="absolute flex size-7 items-center justify-center rounded-full bg-black/60 text-white">
        <AppIcon name="play" :size="14" />
      </span>
    </template>
    <AppIcon v-else name="dumbbell" :size="24" />
  </span>
</template>
