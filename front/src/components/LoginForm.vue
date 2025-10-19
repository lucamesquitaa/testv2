<template>
  <form @submit.prevent="handleSubmit" class="login-form">
    <div class="form-group">
      <label for="email">E-mail</label>
      <input
        id="email"
        v-model="formData.email"
        type="email"
        placeholder="Digite seu e-mail"
        :class="{ 'error': errors.email }"
        required
      />
      <span v-if="errors.email" class="error-message">{{ errors.email }}</span>
    </div>

    <div class="form-group">
      <label for="password">Senha</label>
      <div class="password-input">
        <input
          id="password"
          v-model="formData.password"
          :type="showPassword ? 'text' : 'password'"
          placeholder="Digite sua senha"
          :class="{ 'error': errors.password }"
          required
        />
        <button
          type="button"
          @click="togglePassword"
          class="password-toggle"
        >
          {{ showPassword ? '👁️' : '👁️‍🗨️' }}
        </button>
      </div>
      <span v-if="errors.password" class="error-message">{{ errors.password }}</span>
    </div>

    <button
      type="submit"
      class="login-button"
      :disabled="isLoading"
    >
      <span v-if="isLoading" class="loading-spinner"></span>
      {{ isLoading ? loadingText : submitText }}
    </button>

    <div v-if="loginError" class="error-message general-error">
      {{ loginError }}
    </div>
  </form>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'

interface LoginFormData {
  email: string
  password: string
}

interface FormErrors {
  email?: string
  password?: string
}

interface Props {
  submitText?: string
  loadingText?: string
  showRememberMe?: boolean
  showForgotPassword?: boolean
}

// Props com valores padrão
const props = withDefaults(defineProps<Props>(), {
  submitText: 'Entrar',
  loadingText: 'Entrando...',
  showRememberMe: false,
  showForgotPassword: false
})

// Emits
const emit = defineEmits<{
  'submit': [formData: LoginFormData]
  'forgot-password': []
}>()

// Estado reativo do formulário
const formData = reactive<LoginFormData>({
  email: '',
  password: ''
})

// Estado de controle
const showPassword = ref(false)
const isLoading = ref(false)
const loginError = ref('')
const errors = reactive<FormErrors>({})

// Funções
const togglePassword = () => {
  showPassword.value = !showPassword.value
}

const validateForm = (): boolean => {
  // Limpar erros anteriores
  Object.keys(errors).forEach(key => delete errors[key as keyof FormErrors])
  
  let isValid = true

  // Validar email
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!formData.email) {
    errors.email = 'E-mail é obrigatório'
    isValid = false
  } else if (!emailRegex.test(formData.email)) {
    errors.email = 'E-mail inválido'
    isValid = false
  }

  // Validar senha
  if (!formData.password) {
    errors.password = 'Senha é obrigatória'
    isValid = false
  } 

  return isValid
}

const handleSubmit = () => {
  if (!validateForm()) return
  
  emit('submit', { ...formData })
}

// Funções expostas para o componente pai
const setLoading = (loading: boolean) => {
  isLoading.value = loading
}

const setError = (error: string) => {
  loginError.value = error
}

const clearForm = () => {
  formData.email = ''
  formData.password = ''
  loginError.value = ''
  Object.keys(errors).forEach(key => delete errors[key as keyof FormErrors])
}

// Expor funções para o componente pai
defineExpose({
  setLoading,
  setError,
  clearForm
})
</script>

<style scoped>
.login-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label {
  color: #333;
  font-weight: 600;
  font-size: 14px;
}

.form-group input {
  padding: 14px 16px;
  border: 2px solid #e1e5e9;
  border-radius: 8px;
  font-size: 16px;
  transition: all 0.3s ease;
  background: #fafbfc;
}

.form-group input:focus {
  outline: none;
  border-color: #667eea;
  background: white;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-group input.error {
  border-color: #ef4444;
  background: #fef2f2;
}

.password-input {
  position: relative;
  display: flex;
  align-items: center;
}

.password-toggle {
  position: absolute;
  right: 12px;
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  color: #666;
  font-size: 18px;
  transition: color 0.3s ease;
}

.password-toggle:hover {
  color: #333;
}

.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 8px 0;
}

.remember-me {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  font-size: 14px;
  color: #666;
}

.remember-me input[type="checkbox"] {
  width: 16px;
  height: 16px;
  margin: 0;
}

.forgot-password {
  color: #667eea;
  text-decoration: none;
  font-size: 14px;
  font-weight: 500;
  transition: color 0.3s ease;
}

.forgot-password:hover {
  color: #5a6fd8;
}

.login-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 8px;
  padding: 16px 24px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-top: 12px;
}

.login-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
}

.login-button:disabled {
  opacity: 0.7;
  cursor: not-allowed;
  transform: none;
}

.loading-spinner {
  width: 18px;
  height: 18px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-message {
  color: #ef4444;
  font-size: 12px;
  font-weight: 500;
}

.general-error {
  text-align: center;
  background: #fef2f2;
  padding: 12px;
  border-radius: 8px;
  border: 1px solid #fecaca;
  margin-top: 8px;
}

/* Responsividade */
@media (max-width: 480px) {
  .form-group input {
    padding: 12px 14px;
    font-size: 16px; /* Evita zoom no iOS */
  }
}
</style>