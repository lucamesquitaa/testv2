<template>
  <div class="login-container">
    <!-- Debug Component (temporário) -->
    <ApiDebug />
    
    <div class="login-card">
      <div class="login-header">
        <h1>Entrar</h1>
        <p>Entre na sua conta para continuar</p>
      </div>

      <form @submit.prevent="handleLogin" class="login-form">
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
          :disabled="loading"
        >
          <span v-if="loading" class="loading-spinner"></span>
          {{ loading ? 'Entrando...' : 'Entrar' }}
        </button>

        <div v-if="error" class="error-message general-error">
          {{ error }}
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import ApiDebug from '@/components/ApiDebug.vue'

interface LoginForm {
  email: string
  password: string
  rememberMe: boolean
}

interface FormErrors {
  email?: string
  password?: string
}

const router = useRouter()
const { login, loading, error, clearError } = useAuth()

// Estado reativo do formulário
const formData = reactive<LoginForm>({
  email: '',
  password: '',
  rememberMe: false
})

// Estado de controle
const showPassword = ref(false)
const errors = reactive<FormErrors>({})

// Watch para limpar erro quando usuário digita
watch(() => formData.email, clearError)
watch(() => formData.password, clearError)

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

const handleLogin = async () => {
  if (!validateForm()) return

  const success = await login({
    email: formData.email,
    password: formData.password,
    rememberMe: formData.rememberMe
  })

  if (success) {
    console.log('Login realizado com sucesso!')
    // Redirecionar para página principal
    await router.push('/home')
  }
}

const showRegister = () => {
  // Implementar navegação para registro ou abrir modal
  console.log('Navegar para registro')
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.login-card {
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  padding: 40px;
  width: 100%;
  max-width: 400px;
  animation: slideUp 0.6s ease-out;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.login-header {
  text-align: center;
  margin-bottom: 32px;
}

.login-header h1 {
  color: #333;
  font-size: 28px;
  font-weight: 700;
  margin: 0 0 8px 0;
}

.login-header p {
  color: #666;
  font-size: 16px;
  margin: 0;
}

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

.login-footer {
  margin-top: 32px;
  text-align: center;
}

.login-footer p {
  color: #666;
  font-size: 14px;
  margin: 0;
}

.login-footer a {
  color: #667eea;
  text-decoration: none;
  font-weight: 600;
  transition: color 0.3s ease;
}

.login-footer a:hover {
  color: #5a6fd8;
}

/* Responsividade */
@media (max-width: 480px) {
  .login-container {
    padding: 16px;
  }
  
  .login-card {
    padding: 32px 24px;
  }
  
  .login-header h1 {
    font-size: 24px;
  }
  
  .form-group input {
    padding: 12px 14px;
    font-size: 16px; /* Evita zoom no iOS */
  }
}
</style>