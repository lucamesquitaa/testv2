# Sistema de Login - Vue 3 + TypeScript

Este projeto inclui um sistema completo de autenticação com componentes reutilizáveis.

## Componentes Criados

### 1. LoginView.vue
Página principal de login com interface moderna e responsiva.

**Localização:** `src/views/LoginView.vue`

**Características:**
- Interface moderna com gradiente
- Validação de formulário em tempo real
- Feedback visual de loading
- Responsivo para mobile
- Animações suaves

### 2. LoginForm.vue
Componente reutilizável de formulário de login.

**Localização:** `src/components/LoginForm.vue`

**Props:**
- `submitText` (string): Texto do botão de submit (padrão: "Entrar")
- `loadingText` (string): Texto durante loading (padrão: "Entrando...")
- `showRememberMe` (boolean): Mostrar checkbox "Lembrar de mim" (padrão: true)
- `showForgotPassword` (boolean): Mostrar link "Esqueceu a senha?" (padrão: true)

**Events:**
- `submit`: Emitido quando formulário é válido e submetido
- `forgot-password`: Emitido quando link "Esqueceu a senha" é clicado

**Exemplo de uso:**
```vue
<template>
  <LoginForm
    submit-text="Fazer Login"
    loading-text="Carregando..."
    :show-remember-me="false"
    @submit="handleLoginSubmit"
    @forgot-password="handleForgotPassword"
  />
</template>
```

### 3. AuthService
Serviço para gerenciar autenticação.

**Localização:** `src/services/authService.ts`

**Métodos principais:**
- `login(credentials)`: Realizar login
- `logout()`: Realizar logout
- `isAuthenticated()`: Verificar se usuário está logado
- `getToken()`: Obter token atual
- `getUser()`: Obter dados do usuário
- `authenticatedFetch()`: Fetch com token automático

### 4. useAuth Composable
Hook do Vue para gerenciar estado de autenticação.

**Localização:** `src/composables/useAuth.ts`

**Propriedades reativas:**
- `user`: Dados do usuário atual
- `authenticated`: Status de autenticação
- `loading`: Estado de loading
- `error`: Mensagens de erro

**Métodos:**
- `login(credentials)`: Função de login
- `logout()`: Função de logout
- `clearError()`: Limpar erros
- `requireAuth()`: Guard para rotas protegidas

## Como Usar

### 1. Credenciais de Teste
Para testar o login, use:
- **E-mail:** test@test.com
- **Senha:** 123456

### 2. Integrar com sua API
No arquivo `src/services/authService.ts`, atualize a `baseUrl` e remova a simulação:

```typescript
private readonly baseUrl = 'https://sua-api.com/api'

// Remove ou comenta a simulação no método login()
```

### 3. Usar em outros componentes
```vue
<script setup lang="ts">
import { useAuth } from '@/composables/useAuth'

const { user, authenticated, logout } = useAuth()
</script>

<template>
  <div v-if="authenticated">
    <p>Olá, {{ user?.name }}!</p>
    <button @click="logout">Sair</button>
  </div>
</template>
```

### 4. Proteger rotas
No arquivo de rotas (`src/router/index.ts`):

```typescript
import { useAuth } from '@/composables/useAuth'

router.beforeEach((to) => {
  const { requireAuth } = useAuth()
  
  if (to.meta.requiresAuth && !requireAuth()) {
    return '/'
  }
})
```

## Funcionalidades

### ✅ Implementado
- [x] Interface de login moderna
- [x] Validação de formulário
- [x] Gerenciamento de estado
- [x] Persistência no localStorage
- [x] Componente reutilizável
- [x] Composable para Vue 3
- [x] TypeScript completo
- [x] Design responsivo
- [x] Animações e transições

### 🔄 Para implementar (opcional)
- [ ] Recuperação de senha
- [ ] Registro de usuário
- [ ] Login social (Google, Facebook)
- [ ] Autenticação de dois fatores
- [ ] Refresh token automático
- [ ] Lembrança de sessão

## Estrutura de Arquivos

```
src/
├── views/
│   └── LoginView.vue          # Página de login
├── components/
│   └── LoginForm.vue          # Componente de formulário
├── services/
│   └── authService.ts         # Serviço de autenticação
├── composables/
│   └── useAuth.ts             # Composable de auth
└── router/
    └── index.ts               # Configuração de rotas
```

## Estilos e Customização

O componente usa CSS moderno com:
- CSS Grid e Flexbox
- Variáveis CSS customizáveis
- Animações com `@keyframes`
- Design responsivo com media queries
- Gradientes e shadows

Para customizar cores, edite as variáveis no arquivo CSS do componente.

## Dependências

O sistema usa apenas dependências padrão do Vue 3:
- Vue 3
- Vue Router 4
- TypeScript

Não requer bibliotecas externas para funcionar.