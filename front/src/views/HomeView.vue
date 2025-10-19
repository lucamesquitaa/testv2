<script setup lang="ts">
import { ref } from 'vue'
import TheWelcome from '../components/TheWelcome.vue'
import RegisterModal from '../components/RegisterModal.vue'

const isModalVisible = ref(false)
const welcomeComponent = ref()

const openModal = () => {
  isModalVisible.value = true
}

const closeModal = () => {
  isModalVisible.value = false
}


const handleRegistration = async (userData: any) => {
  try {
    // Mapear os dados para o formato esperado pela API
    const apiData = {
      Name: userData.name,
      Travel: userData.travel,
      DateIn: userData.dateIn,
      DateOut: userData.dateOut,
      Status: 'Pendente' // Status padrão
    }
    
    console.log('Enviando dados:', apiData)
    
    // Definir múltiplas URLs para tentar
    const urls = [
      '/api/travels',                          // Proxy do Vite
      'http://localhost:8000/api/travels'      // Acesso direto (desenvolvimento local)
    ]
    
    let lastError = null
    
    for (const url of urls) {
      try {
        console.log('Tentando URL:', url)
        
        const response = await fetch(url, {
          method: 'POST',
          mode: url.startsWith('/') ? 'same-origin' : 'cors',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify(apiData)
        })
        
        if (!response.ok) {
          let errorMessage = `Erro HTTP: ${response.status}`
          try {
            const errorData = await response.json()
            errorMessage = errorData.message || errorMessage
            console.error('Erro da API:', errorData)
          } catch (e) {
            console.error('Erro ao parsear resposta de erro:', e)
          }
          throw new Error(errorMessage)
        }
        
        const data = await response.json()
        console.log('Resposta do servidor:', data)
        alert('Viagem cadastrada com sucesso!')
        closeModal()
        
        // Atualizar lista de viagens através da referência do componente
        if (welcomeComponent.value && welcomeComponent.value.fetchData) {
          await welcomeComponent.value.fetchData()
        }
        return // Sucesso, sair do loop
        
      } catch (error) {
        console.error(`Erro com URL ${url}:`, error)
        lastError = error
        continue // Tentar próxima URL
      }
    }
    
    // Se chegou aqui, todas as URLs falharam
    throw lastError
    
  } catch (error: any) {
    console.error('Erro ao cadastrar viagem (todas as URLs falharam):', error)
    if (error.name === 'TypeError' && error.message.includes('Failed to fetch')) {
      alert('Erro de conexão: Verifique se a API está rodando')
    } else {
      alert('Erro ao cadastrar viagem: ' + error.message)
    }
  }
}
</script>

<template>
  <div class="home">
    <div class="actions">
      <button @click="openModal" class="register">
        📝 Cadastrar Viagem !
      </button>
      
    </div>
    <div class="welcome">
      <TheWelcome ref="welcomeComponent" />
    </div>
    
    <!-- Modal de Cadastro -->
    <RegisterModal
      :is-visible="isModalVisible"
      @close="closeModal"
      @submit="handleRegistration"
    />
  </div>
  
</template>

<style scoped>
.home {
  width: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}
.actions {
  margin:10px;
}
.register{
  background-color: #4CAF50;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-size: 16px;
}

</style>
