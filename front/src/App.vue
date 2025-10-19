<script setup lang="ts">
import { RouterView } from 'vue-router'
import LoadingSpinner from '@/components/LoadingSpinner.vue'
import { useLoading } from '@/composables/useLoading'

const { isLoading, message, overlay } = useLoading()
</script>

<template>
  <RouterView />
  
  <!-- Loading Spinner Global -->
  <LoadingSpinner 
    v-if="isLoading" 
    :overlay="overlay" 
    :message="message"
    size="medium"
    color="#007bff"
  />
</template>

