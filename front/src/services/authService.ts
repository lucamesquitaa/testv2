import { useLoading } from "@/composables/useLoading"

interface LoginCredentials {
  email: string
  password: string
  rememberMe?: boolean
}

interface AuthResponse {
  success: boolean
  message: string
  data: {
    token: string
    user: {
      id: number
      email: string
      email_verified_at: string | null
      created_at: string
      updated_at: string
    }
  }
}

interface User {
  id: number
  email: string
  email_verified_at: string | null
  created_at: string
  updated_at: string
}

class AuthService {
  private readonly baseUrl = 'http://localhost:8000/api'
  private readonly tokenKey = 'auth_token'
  private readonly userKey = 'auth_user'

  /**
   * Testa a conectividade com a API
   */
  async testConnection(): Promise<boolean> {
    try {
      console.log('Testando conexão com:', this.baseUrl)
      const response = await fetch(`${this.baseUrl}/health`, {
        method: 'GET',
        mode: 'cors',
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      
      console.log('Status da conexão:', response.status)
      console.log('Headers da resposta de saúde:', Object.fromEntries(response.headers.entries()))
      
      if (response.ok) {
        const data = await response.text()
        console.log('Resposta de saúde:', data)
      }
      
      return response.ok
    } catch (error) {
      console.error('Erro ao testar conexão:', error)
      return false
    }
  }

  /**
   * Realiza o login do usuário
   */
  async login(credentials: LoginCredentials): Promise<{ token: string; user: User }> {
    const { startLoading, stopLoading } = useLoading()
    try {
      startLoading({ message: 'Entrando...' })
      console.log('Tentando fazer login com:', { email: credentials.email })
      console.log('URL da API:', `${this.baseUrl}/login`)
      
      // Verificar se a API está acessível
      let response: Response
      try {
        response = await fetch(`${this.baseUrl}/login`, {
          method: 'POST',
          mode: 'cors', // Explicitamente habilitar CORS
          credentials: 'include', // Incluir cookies se necessário
          headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                        'X-Requested-With': 'XMLHttpRequest',
                        'Authorization': `Bearer ${authService.getToken()}`
                    },
          body: JSON.stringify({
            email: credentials.email,
            password: credentials.password,
          }),
        })
        
      } catch (fetchError) {
        console.error('Erro na requisição (possivelmente CORS):', fetchError)
        stopLoading()
        // Verificar se é erro de CORS
        if (fetchError instanceof TypeError) {
          
          throw new Error(`Erro de CORS ou conexão: ${fetchError.message}. Verifique se a API está rodando em http://localhost:8000 e se o CORS está configurado corretamente.`)
        }
     
        throw new Error('Não foi possível conectar com a API. Verifique se o servidor está funcionando.')
      }

      console.log('Resposta da API status:', response.status)
      console.log('Headers da resposta:', Object.fromEntries(response.headers.entries()))

      // Verificar o Content-Type da resposta
      const contentType = response.headers.get('content-type')
      console.log('Content-Type:', contentType)

      if (!contentType || !contentType.includes('application/json')) {
        console.warn('Resposta não é JSON válido. Content-Type:', contentType)
        const textResponse = await response.text()
        console.error('Conteúdo da resposta (HTML/texto):', textResponse.substring(0, 500))
        throw new Error(`API retornou uma resposta inválida (não JSON). Content-Type: ${contentType}. Conteúdo: ${textResponse.substring(0, 100)}...`)
      }

      if (!response.ok) {
        let errorMessage = 'Erro no login'
        try {
          const errorData = await response.json()
          errorMessage = errorData.message || errorMessage
        } catch (jsonError) {
          console.error('Erro ao parsear resposta de erro:', jsonError)
          errorMessage = `Erro HTTP ${response.status}: ${response.statusText}`
        }
        throw new Error(errorMessage)
      }

      const data = await response.json()
      console.log('Resposta da API:', data)

      if (!data) {
        throw new Error('Resposta vazia da API')
      }

      // Verificar se a resposta tem a estrutura esperada
      if (!data.success) {
        throw new Error(data.message || 'Login falhou')
      }

      if (!data.data || !data.data.token || !data.data.user) {
        throw new Error('Resposta da API não contém os dados esperados')
      }

      // Salvar token e dados do usuário
      this.setToken(data.data.token)
      this.setUser(data.data.user)
      stopLoading()
      return {
        token: data.data.token,
        user: data.data.user
      }
    } catch (error) {
      console.error('Erro completo no login:', error)
      stopLoading()
      // Adicionar informações de debug mais detalhadas
      if (error instanceof TypeError && error.message.includes('fetch')) {
        throw new Error('Erro de conexão: Não foi possível conectar com a API. Verifique se o servidor está rodando em http://localhost:8000')
      }
      
      throw error instanceof Error ? error : new Error('Erro no login')
    }
  }

  /**
   * Realiza o logout do usuário
   */
  async logout(): Promise<void> {
    try {
      // Chamar endpoint de logout na API se necessário
      const token = this.getToken()
      if (token) {
        await fetch(`${this.baseUrl}/logout`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${authService.getToken()}`,
          },
        })
      }
    } catch (error) {
      console.error('Erro no logout:', error)
    } finally {
      // Limpar dados locais independente do resultado da API
      this.clearAuthData()
    }
  }

  /**
   * Verifica se o usuário está autenticado
   */
  isAuthenticated(): boolean {
    const token = this.getToken()
    if (!token) return false

    // Aqui você pode adicionar validação do token
    // Por exemplo, verificar se não expirou
    return this.isTokenValid(token)
  }

  /**
   * Obtém o token armazenado
   */
  getToken(): string | null {
    return localStorage.getItem(this.tokenKey)
  }

  /**
   * Obtém o usuário armazenado
   */
  getUser(): User | null {
    const userJson = localStorage.getItem(this.userKey)
    return userJson ? JSON.parse(userJson) : null
  }

  /**
   * Armazena o token
   */
  setToken(token: string): void {
    localStorage.setItem(this.tokenKey, token)
  }

  /**
   * Armazena os dados do usuário
   */
  setUser(user: User): void {
    localStorage.setItem(this.userKey, JSON.stringify(user))
  }

  /**
   * Remove todos os dados de autenticação
   */
  clearAuthData(): void {
    localStorage.removeItem(this.tokenKey)
    localStorage.removeItem(this.userKey)
  }

  /**
   * Valida se o token está válido (simples validação - em produção use JWT decode)
   */
  private isTokenValid(token: string): boolean {
    // Validação simples - em produção você pode decodificar JWT e verificar expiração
    return token.length > 0
  }

  /**
   * Renova o token de acesso
   */
  async refreshToken(): Promise<string | null> {
    try {
      const response = await fetch(`${this.baseUrl}/refresh-token`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'Authorization': `Bearer ${authService.getToken()}`
        },
      })

      if (!response.ok) {
        throw new Error('Falha ao renovar token')
      }

      const data = await response.json()
      const newToken = data.token

      if (newToken) {
        this.setToken(newToken)
        return newToken
      }

      return null
    } catch (error) {
      console.error('Erro ao renovar token:', error)
      return null
    }
  }
}

// Instância singleton do serviço de autenticação
const authService = new AuthService()

export { authService, type LoginCredentials, type User }
export default authService