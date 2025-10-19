<template>
  <div class="api-debug">
    <h3>🔧 Debug da API</h3>
    
    <div class="debug-section">
      <h4>Informações de Conexão</h4>
      <p><strong>URL da API:</strong> {{ apiUrl }}</p>
      <p><strong>Status:</strong> 
        <span :class="connectionStatus">{{ statusText }}</span>
      </p>
    </div>

    <div class="debug-actions">
      <button @click="testConnection" :disabled="isTestingConnection">
        {{ isTestingConnection ? 'Testando...' : 'Testar Conexão' }}
      </button>
      
      <button @click="testLogin" :disabled="isTestingLogin">
        {{ isTestingLogin ? 'Testando...' : 'Testar Login' }}
      </button>
    </div>

    <div v-if="logs.length > 0" class="debug-logs">
      <h4>Logs de Debug</h4>
      <div class="logs-container">
        <div 
          v-for="(log, index) in logs" 
          :key="index" 
          :class="['log-entry', log.type]"
        >
          <span class="log-timestamp">{{ log.timestamp }}</span>
          <span class="log-message">{{ log.message }}</span>
        </div>
      </div>
      <button @click="clearLogs" class="clear-logs">Limpar Logs</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { authService } from '@/services/authService'

interface LogEntry {
  timestamp: string
  message: string
  type: 'info' | 'success' | 'error' | 'warning'
}

const apiUrl = 'http://localhost:8000/api'
const isConnected = ref<boolean | null>(null)
const isTestingConnection = ref(false)
const isTestingLogin = ref(false)
const logs = ref<LogEntry[]>([])

const connectionStatus = computed(() => {
  if (isConnected.value === null) return 'status-unknown'
  return isConnected.value ? 'status-connected' : 'status-disconnected'
})

const statusText = computed(() => {
  if (isConnected.value === null) return 'Não testado'
  return isConnected.value ? 'Conectado ✅' : 'Desconectado ❌'
})

const addLog = (message: string, type: LogEntry['type'] = 'info') => {
  logs.value.unshift({
    timestamp: new Date().toLocaleTimeString(),
    message,
    type
  })
  
  // Manter apenas os últimos 20 logs
  if (logs.value.length > 20) {
    logs.value = logs.value.slice(0, 20)
  }
}

const testConnection = async () => {
  isTestingConnection.value = true
  addLog('Iniciando teste de conexão...', 'info')
  
  try {
    const connected = await authService.testConnection()
    isConnected.value = connected
    
    if (connected) {
      addLog('✅ Conexão com API bem-sucedida', 'success')
    } else {
      addLog('❌ Falha na conexão com API', 'error')
    }
  } catch (error) {
    isConnected.value = false
    addLog(`❌ Erro ao testar conexão: ${error}`, 'error')
  } finally {
    isTestingConnection.value = false
  }
}

const testLogin = async () => {
  isTestingLogin.value = true
  addLog('Iniciando teste de login com usuário admin...', 'info')
  
  try {
    // Usar credenciais do usuário admin criado no seeder
    const result = await authService.login({
      email: 'admin@admin.com',
      password: 'admin'
    })
    
    addLog('✅ Login de teste bem-sucedido', 'success')
    addLog(`Token recebido: ${result.token.substring(0, 20)}...`, 'info')
  } catch (error) {
    addLog(`❌ Erro no login de teste: ${error}`, 'error')
  } finally {
    isTestingLogin.value = false
  }
}

const clearLogs = () => {
  logs.value = []
}

// Testar conexão automaticamente ao carregar o componente
onMounted(() => {
  testConnection()
})
</script>

<style scoped>
.api-debug {
  background: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  padding: 1rem;
  margin: 1rem 0;
  font-family: monospace;
  font-size: 0.9rem;
}

.debug-section {
  margin-bottom: 1rem;
}

.debug-section h4 {
  margin: 0 0 0.5rem 0;
  color: #495057;
}

.status-connected {
  color: #28a745;
  font-weight: bold;
}

.status-disconnected {
  color: #dc3545;
  font-weight: bold;
}

.status-unknown {
  color: #6c757d;
  font-weight: bold;
}

.debug-actions {
  margin: 1rem 0;
}

.debug-actions button {
  margin-right: 0.5rem;
  margin-bottom: 0.5rem;
  padding: 0.5rem 1rem;
  border: 1px solid #6c757d;
  border-radius: 4px;
  background: white;
  cursor: pointer;
  transition: all 0.2s;
}

.debug-actions button:hover:not(:disabled) {
  background: #e9ecef;
}

.debug-actions button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.debug-logs {
  margin-top: 1rem;
  border-top: 1px solid #dee2e6;
  padding-top: 1rem;
}

.logs-container {
  max-height: 200px;
  overflow-y: auto;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  padding: 0.5rem;
  background: white;
  margin-bottom: 0.5rem;
}

.log-entry {
  display: flex;
  margin-bottom: 0.25rem;
  font-size: 0.8rem;
}

.log-timestamp {
  color: #6c757d;
  margin-right: 0.5rem;
  min-width: 80px;
}

.log-message {
  flex: 1;
}

.log-entry.success .log-message {
  color: #28a745;
}

.log-entry.error .log-message {
  color: #dc3545;
}

.log-entry.warning .log-message {
  color: #ffc107;
}

.log-entry.info .log-message {
  color: #17a2b8;
}

.clear-logs {
  padding: 0.25rem 0.5rem;
  font-size: 0.8rem;
  border: 1px solid #6c757d;
  border-radius: 4px;
  background: white;
  cursor: pointer;
}

.clear-logs:hover {
  background: #e9ecef;
}
</style>