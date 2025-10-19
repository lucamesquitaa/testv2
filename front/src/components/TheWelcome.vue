<script setup lang="ts">
import { ref, onMounted } from 'vue'
import FilterModal from './FilterModal.vue'
import authService from '@/services/authService'
import router from '@/router'
import { useLoading } from '@/composables/useLoading'

const pessoas = ref<Array<{id: number, name: string, viagem: string, dataIda: string, dataVolta: string, status: string}>>([])
const { startLoading, stopLoading, isLoading, message, overlay } = useLoading()
const isModalVisibleFilter = ref(false)
const openModalFilter = () => {
  isModalVisibleFilter.value = true
}

const closeModalFilter = () => {
  isModalVisibleFilter.value = false
}

async function handleFilter(filterData: any) {
  console.log('Filtro aplicado:', filterData)

  // Filtrar os dados com base no status selecionado
  const statusFilter = filterData.travel; // Supondo que o campo 'travel' contém o status
    
  // Sempre buscar os dados primeiro
  await fetchData();
  
  // Em seguida, aplicar o filtro se houver um status selecionado
  if (statusFilter) {
    pessoas.value = pessoas.value.filter(pessoa => pessoa.status === statusFilter)
  }
  // Se não houver filtro, mantém todos os dados (já carregados pelo fetchData)

  closeModalFilter();
}

const fetchDataLocal = (pessoa) => {
  pessoas.value = [
    ...pessoas.value,
    {
      id: pessoa.id,
      name: pessoa.Name,
      viagem: pessoa.Travel,
      dataIda: pessoa.DateIn,
      dataVolta: pessoa.DateOut,
      status: pessoa.Status
    }
  ]
}


async function fetchData(){
  try {
    startLoading({message: 'Carregando dados...', overlay: true});
    // Definir múltiplas URLs para tentar
    const urls = [
      '/api/travels',                          // Proxy do Vite
      'http://localhost:8000/api/travels'      // Acesso direto (desenvolvimento local)
    ]

    //se não é admin, não pode dar getAll !!!!
    if(!authService.getToken()){
      stopLoading()
      return;
    }

    
    let lastError = null
    
    for (const url of urls) {
      try {
        console.log('Tentando buscar dados da URL:', url)
        
        const response = await fetch(url, {
          method: 'GET',
          mode: url.startsWith('/') ? 'same-origin' : 'cors',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': `Bearer ${authService.getToken()}`
          }
        })
        
        if (!response.ok) {
          throw new Error(`Erro HTTP: ${response.status}`)
        }
        
        const data = await response.json()
        console.log('Resposta da API:', data)
        
        // Verificar se a resposta tem o formato esperado
        const travels = data.success ? data.data : (Array.isArray(data) ? data : [])
        
        pessoas.value = travels.map((item: any) => ({
          id: item.id,
          name: item.Name,
          viagem: item.Travel,
          dataIda: item.DateIn,
          dataVolta: item.DateOut,
          status: item.Status
        }))
        stopLoading()
        console.log('Dados processados:', pessoas.value)
        return // Sucesso, sair do loop
        
      } catch (error) {
        console.error(`Erro com URL ${url}:`, error)
        lastError = error
        stopLoading()
        continue // Tentar próxima URL
      }
    }
    
    // Se chegou aqui, todas as URLs falharam
    throw lastError
    
  } catch (error) {
    stopLoading()
    console.error('Erro ao buscar dados (todas as URLs falharam):', error)
    // Mostrar dados vazios em caso de erro
    pessoas.value = []
  }
}

onMounted(() => {
  fetchData();
})

 const voltarLogin = () => {
    authService.logout();
    router.push('/'); // Redireciona para a página de login
  }

async function aprovarViagem(id: number) {
  try {
    if (!confirm('Tem certeza que deseja aprovar esta viagem?')) {
      return
    }

    if(!authService.getToken()){
      alert('Usuário sem permissão para esta ação. Por favor, faça login.')
      return;
    }

    // Definir múltiplas URLs para tentar
    const urls = [
      '/api/travels',                          // Proxy do Vite
      'http://localhost:8000/api/travels'      // Acesso direto (desenvolvimento local)
    ]
    
    let lastError = null
    startLoading({message: 'Aprovando...', overlay: true});
    for (const url of urls) {
      try {
        console.log('Tentando aprovar viagem na URL:', `${url}/${id}`)
        
        const response = await fetch(`${url}/${id}`, {
          method: 'PUT',
          mode: url.startsWith('/') ? 'same-origin' : 'cors',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': `Bearer ${authService.getToken()}`
          },
          body: JSON.stringify({
            Status: 'Aprovada'
          })
        })
        
        if (!response.ok) {
          const errorData = await response.json()
          throw new Error(errorData.message || `Erro HTTP: ${response.status}`)
        }

        const data = await response.json()
        console.log('Viagem aprovada com sucesso:', data)
        
        // Recarregar os dados após aprovação
        await fetchData()
        alert('Viagem aprovada com sucesso!')
        stopLoading()
        return // Sucesso, sair do loop
        
      } catch (error) {
        console.error(`Erro com URL ${url}:`, error)
        lastError = error
        continue // Tentar próxima URL
      }
    }
    
    throw lastError
    
  } catch (error: any) {
    stopLoading()
    console.error('Erro ao aprovar viagem:', error)
    alert('Erro ao aprovar viagem: ' + error.message)
  }
}
async function cancelarViagem(id: number) {
  startLoading({message: 'Cancelando...', overlay: true});
  try {
    if (!confirm('Tem certeza que deseja cancelar esta viagem?')) {
      return
    }

    if(!authService.getToken()){
      alert('Usuário sem permissão para esta ação. Por favor, faça login.')
      return;
    }

    // Definir múltiplas URLs para tentar
    const urls = [
      '/api/travels',                          // Proxy do Vite
      'http://localhost:8000/api/travels'      // Acesso direto (desenvolvimento local)
    ]
    
    let lastError = null
    
    for (const url of urls) {
      try {
        console.log('Tentando cancelar viagem na URL:', `${url}/${id}`)
        
        const response = await fetch(`${url}/${id}`, {
          method: 'PUT',
          mode: url.startsWith('/') ? 'same-origin' : 'cors',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': `Bearer ${authService.getToken()}`
          },
          body: JSON.stringify({
            Status: 'Cancelada'
          })
        })
        
        if (!response.ok) {
          const errorData = await response.json()
          throw new Error(errorData.message || `Erro HTTP: ${response.status}`)
        }

        const data = await response.json()
        console.log('Viagem cancelada com sucesso:', data)
        
        // Recarregar os dados após cancelamento
        await fetchData()
        stopLoading()
        alert('Viagem cancelada com sucesso!')
        return // Sucesso, sair do loop
        
      } catch (error) {
        console.error(`Erro com URL ${url}:`, error)
        lastError = error
        continue // Tentar próxima URL
      }
    }
    
    throw lastError
    
  } catch (error: any) {
    stopLoading()
    console.error('Erro ao cancelar viagem:', error)
    alert('Erro ao cancelar viagem: ' + error.message)
  }
}

// Expor as funções para que componentes pais possam acessá-las
defineExpose({
  fetchData,
  fetchDataLocal
})

</script>

<template>
  <!-- Modal de Filtro -->
    <FilterModal
      :is-visible="isModalVisibleFilter"
      @close="closeModalFilter"
      @submit="handleFilter"
    />
    <button @click="openModalFilter" class="filter">
        Filtrar por Status!
      </button>
    <button @click="voltarLogin" class="filter2">
        Sair
    </button>
  <table>
    <thead>
      <tr>
        <th>ID</th>
        <th>Nome</th>
        <th>Viagem</th>
        <th>Data de Ida</th>
        <th>Data de Volta</th>
        <th>Status</th>
        <th>Aprovação</th>
        <th>Cancelar</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="pessoa in pessoas" :key="pessoa.id" :class="{ 
        'aprovada': pessoa.status === 'Aprovada',
        'cancelada': pessoa.status === 'Cancelada'
      }">
        <td>{{ pessoa.id }}</td>
        <td>{{ pessoa.name }}</td>
        <td>{{ pessoa.viagem }}</td>
        <td>{{ pessoa.dataIda }}</td>
        <td>{{ pessoa.dataVolta }}</td>
        <td>{{ pessoa.status }}</td>
        <td>
          <v-icon name="fa-plane-departure" @click="aprovarViagem(pessoa.id)" />
        </td>
        <td>
          <v-icon name="bi-trash-fill" @click="cancelarViagem(pessoa.id)" />
        </td>
      </tr>
    </tbody>
  </table>
</template>

<style scoped>
table {
  width: 100%;
  border-collapse: collapse;
  margin: 0 30px;
}

th,
td {
  padding: 12px 15px;
  border: 1px solid #ddd;
}

th {
  background-color: #f4f4f4;
}

v-icon {
  cursor: pointer;
  transition: transform 0.2s;
}

v-icon:hover {
  transform: scale(1.2);
}

.aprovada {
  background-color: #d4edda !important;
  color: #155724;
}

.aprovada td {
  background-color: #d4edda;
  border-color: #c3e6cb;
}

.cancelada {
  background-color: #f8d7da !important;
  color: #721c24;
}

.cancelada td {
  background-color: #f8d7da;
  border-color: #f5c6cb;
}

.filter {
  margin: 20px 30px;
  padding: 10px 20px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: background-color 0.2s;
}
.filter2 {
  margin: 20px 30px;
  padding: 10px 20px;
  background-color: #3a3a3a;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: background-color 0.2s;
}

.filter:hover {
  background-color: #0056b3;
}
</style>
