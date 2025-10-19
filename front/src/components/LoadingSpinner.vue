<template>
  <div 
    :class="[
      'loading-spinner',
      { 'overlay': overlay },
      sizeClass
    ]"
  >
    <div class="spinner" :style="spinnerStyle">
      <div class="spinner-circle"></div>
    </div>
    <p v-if="message" class="loading-message">{{ message }}</p>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  size?: 'small' | 'medium' | 'large'
  color?: string
  overlay?: boolean
  message?: string
}

const props = withDefaults(defineProps<Props>(), {
  size: 'medium',
  color: '#3b82f6',
  overlay: false,
  message: ''
})

const sizeClass = computed(() => `spinner-${props.size}`)

const spinnerStyle = computed(() => ({
  borderTopColor: props.color,
  borderLeftColor: props.color
}))
</script>

<style scoped>
.loading-spinner {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12px;
}

.loading-spinner.overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(2px);
  z-index: 9999;
}

.spinner {
  border-radius: 50%;
  border-style: solid;
  border-color: transparent;
  animation: spin 1s linear infinite;
}

.spinner-small .spinner {
  width: 20px;
  height: 20px;
  border-width: 2px;
}

.spinner-medium .spinner {
  width: 40px;
  height: 40px;
  border-width: 4px;
}

.spinner-large .spinner {
  width: 60px;
  height: 60px;
  border-width: 6px;
}

.spinner-circle {
  width: 100%;
  height: 100%;
  border-radius: 50%;
}

.loading-message {
  margin: 0;
  color: #6b7280;
  font-size: 14px;
  font-weight: 500;
  text-align: center;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

/* Variações de tema */
.loading-spinner.dark {
  color: white;
}

.loading-spinner.dark.overlay {
  background-color: rgba(0, 0, 0, 0.7);
}

.loading-spinner.dark .loading-message {
  color: #d1d5db;
}

/* Efeito pulsante alternativo */
.loading-spinner.pulse .spinner {
  animation: pulse 1.5s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.5;
    transform: scale(0.8);
  }
}

/* Responsividade */
@media (max-width: 640px) {
  .spinner-large .spinner {
    width: 50px;
    height: 50px;
    border-width: 5px;
  }
  
  .spinner-medium .spinner {
    width: 35px;
    height: 35px;
    border-width: 3px;
  }
}
</style>