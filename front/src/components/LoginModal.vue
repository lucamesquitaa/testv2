<template>
  <div v-if="isOpen" class="modal-overlay" @click="handleOverlayClick">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h2>{{ title }}</h2>
        <button @click="close" class="close-button">×</button>
      </div>
      
      <div class="modal-body">
        <LoginForm
          :submit-text="submitText"
          :loading-text="loadingText"
          :show-remember-me="showRememberMe"
          :show-forgot-password="showForgotPassword"
          @submit="handleLogin"
          @forgot-password="$emit('forgot-password')"
          ref="loginFormRef"
        />
      </div>
      
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { useAuth } from '@/composables/useAuth'
import LoginForm from './LoginForm.vue'
import type { LoginCredentials } from '@/services/authService'

interface Props {
  isOpen: boolean
  title?: string
  submitText?: string
  loadingText?: string
  showRememberMe?: boolean
  showForgotPassword?: boolean
  showFooter?: boolean
  closeOnSuccess?: boolean
  closeOnOverlayClick?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  title: 'Entrar na sua conta',
  submitText: 'Entrar',
  loadingText: 'Entrando...',
  showRememberMe: true,
  showForgotPassword: true,
  showFooter: true,
  closeOnSuccess: true,
  closeOnOverlayClick: true
})

const emit = defineEmits<{
  'close': []
  'login-success': [user: any]
  'forgot-password': []
  'show-register': []
}>()

const { login } = useAuth()
const loginFormRef = ref<InstanceType<typeof LoginForm> | null>(null)

// Funções
const close = () => {
  emit('close')
}

const handleOverlayClick = () => {
  if (props.closeOnOverlayClick) {
    close()
  }
}

const handleLogin = async (credentials: LoginCredentials) => {
  if (!loginFormRef.value) return

  loginFormRef.value.setLoading(true)
  loginFormRef.value.setError('')

  try {
    const success = await login(credentials)
    
    if (success) {
      emit('login-success', credentials)
      
      if (props.closeOnSuccess) {
        close()
      }
    }
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Erro no login'
    loginFormRef.value.setError(errorMessage)
  } finally {
    loginFormRef.value.setLoading(false)
  }
}

// Watch para limpar formulário quando modal fecha
watch(() => props.isOpen, (newValue) => {
  if (!newValue && loginFormRef.value) {
    loginFormRef.value.clearForm()
  }
})
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
  animation: fadeIn 0.3s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.modal-content {
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 450px;
  max-height: 90vh;
  overflow-y: auto;
  animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 32px 16px;
  border-bottom: 1px solid #e1e5e9;
}

.modal-header h2 {
  color: #333;
  font-size: 24px;
  font-weight: 700;
  margin: 0;
}

.close-button {
  background: none;
  border: none;
  font-size: 28px;
  color: #666;
  cursor: pointer;
  padding: 4px;
  line-height: 1;
  transition: color 0.3s ease;
}

.close-button:hover {
  color: #333;
}

.modal-body {
  padding: 24px 32px;
}

.modal-footer {
  padding: 16px 32px 32px;
  text-align: center;
  border-top: 1px solid #f0f0f0;
}

.modal-footer p {
  color: #666;
  font-size: 14px;
  margin: 0;
}

.modal-footer a {
  color: #667eea;
  text-decoration: none;
  font-weight: 600;
  transition: color 0.3s ease;
}

.modal-footer a:hover {
  color: #5a6fd8;
}

/* Responsividade */
@media (max-width: 480px) {
  .modal-overlay {
    padding: 16px;
  }
  
  .modal-header,
  .modal-body,
  .modal-footer {
    padding-left: 24px;
    padding-right: 24px;
  }
  
  .modal-header h2 {
    font-size: 20px;
  }
}

/* Estilo para scroll personalizado */
.modal-content {
  scrollbar-width: thin;
  scrollbar-color: #ccc transparent;
}

.modal-content::-webkit-scrollbar {
  width: 6px;
}

.modal-content::-webkit-scrollbar-track {
  background: transparent;
}

.modal-content::-webkit-scrollbar-thumb {
  background: #ccc;
  border-radius: 3px;
}

.modal-content::-webkit-scrollbar-thumb:hover {
  background: #999;
}
</style>