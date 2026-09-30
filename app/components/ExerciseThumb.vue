<script setup lang="ts">
// Miniatura liviana: solo una imagen con carga diferida, nunca un iframe.
defineProps<{ youtubeId: string | null }>()
</script>

<template>
  <span class="relative flex h-14 w-20 shrink-0 items-center justify-center overflow-hidden rounded-xl bg-brand-soft text-primary ring-1 ring-line">
    <template v-if="youtubeId">
      <img :src="youtubeThumbnail(youtubeId)" alt="" loading="lazy" decoding="async" class="size-full object-cover">
      <span class="absolute flex size-7 items-center justify-center rounded-full bg-black/55 text-white ring-1 ring-white/20 backdrop-blur-sm">
        <AppIcon name="play" :size="14" />
      </span>
    </template>
    <AppIcon v-else name="dumbbell" :size="24" />
  </span>
</template>
