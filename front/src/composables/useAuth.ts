import { ref, computed, readonly } from 'vue'
import { useRouter } from 'vue-router'
import { authService, type LoginCredentials, type User } from '@/services/authService'

// Estado global de autenticação
const isAuthenticated = ref(false)
const currentUser = ref<User | null>(null)
const isLoading = ref(false)
const authError = ref('')

// Inicializar estado baseado no localStorage
const initializeAuth = () => {
  const token = authService.getToken()
  const user = authService.getUser()
  
  if (token && user && authService.isAuthenticated()) {
    isAuthenticated.value = true
    currentUser.value = user
  }
}

export function useAuth() {
  const router = useRouter()

  // Computed properties
  const user = computed(() => currentUser.value)
  const authenticated = computed(() => isAuthenticated.value)
  const loading = computed(() => isLoading.value)
  const error = computed(() => authError.value)

  // Função de login
  const login = async (credentials: LoginCredentials): Promise<boolean> => {
    try {
      isLoading.value = true
      authError.value = ''

      const response = await authService.login(credentials)
      
      isAuthenticated.value = true
      currentUser.value = response.user
      
      return true
    } catch (error) {
      authError.value = error instanceof Error ? error.message : 'Erro no login'
      return false
    } finally {
      isLoading.value = false
    }
  }

  // Função de logout
  const logout = async (): Promise<void> => {
    try {
      isLoading.value = true
      await authService.logout()
    } catch (error) {
      console.error('Erro no logout:', error)
    } finally {
      isAuthenticated.value = false
      currentUser.value = null
      authError.value = ''
      isLoading.value = false
      
      // Redirecionar para login
      await router.push('/')
    }
  }

  // Função para limpar erros
  const clearError = (): void => {
    authError.value = ''
  }

  // Função para verificar se tem permissão
  const hasPermission = (permission: string): boolean => {
    if (!currentUser.value) return false
    
    // Implementar lógica de permissões baseada no seu sistema
    // Por exemplo, verificar se o usuário tem uma role específica
    return true
  }

  // Função para atualizar dados do usuário
  const updateUser = (userData: Partial<User>): void => {
    if (currentUser.value) {
      currentUser.value = { ...currentUser.value, ...userData }
      authService.setUser(currentUser.value)
    }
  }

  // Função para renovar token
  const refreshToken = async (): Promise<boolean> => {
    try {
      const newToken = await authService.refreshToken()
      return !!newToken
    } catch (error) {
      console.error('Erro ao renovar token:', error)
      await logout()
      return false
    }
  }

  // Guard para rotas protegidas
  const requireAuth = (): boolean => {
    if (!isAuthenticated.value) {
      router.push('/')
      return false
    }
    return true
  }

  // Inicializar na primeira execução
  if (!isAuthenticated.value && !isLoading.value) {
    initializeAuth()
  }

  return {
    // Estado (readonly para evitar mutação direta)
    user: readonly(user),
    authenticated: readonly(authenticated),
    loading: readonly(loading),
    error: readonly(error),
    
    // Ações
    login,
    logout,
    clearError,
    hasPermission,
    updateUser,
    refreshToken,
    requireAuth,
  }
}

// Hook para inicialização da aplicação
export function initializeAuthState(): void {
  initializeAuth()
}

// Tipos auxiliares
export interface AuthGuard {
  requireAuth: () => boolean
  requireGuest: () => boolean
}

// Guard para rotas que requerem usuário não autenticado (como login)
export function useGuestGuard(): AuthGuard {
  const router = useRouter()
  
  return {
    requireAuth: (): boolean => {
      if (!isAuthenticated.value) {
        router.push('/')
        return false
      }
      return true
    },
    
    requireGuest: (): boolean => {
      if (isAuthenticated.value) {
        router.push('/home') // ou sua página padrão após login
        return false
      }
      return true
    }
  }
}