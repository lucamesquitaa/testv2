<template>
  <div v-if="isVisible" class="modal-overlay" @click="closeModal">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h2>Cadastro Pedido de Viagem:</h2>
        <button class="close-button" @click="closeModal">&times;</button>
      </div>
      
      <form @submit.prevent="handleSubmit" class="modal-body">
  
        <div class="form-group">
          <label for="name">Nome Completo:</label>
          <input
            id="name"
            v-model="form.name"
            type="text"
            required
            placeholder="Digite seu nome completo"
          />
        </div>
        
        <div class="form-group">
          <label for="travel">Destino Viagem:</label>
          <input
            id="travel"
            v-model="form.travel"
            type="text"
            required
            placeholder="Digite o destino da viagem"
          />
        </div>
        
        <div class="form-group">
          <label for="dateIn">Data de Ida:</label>
          <input
            id="dateIn"
            v-model="form.dateIn"
            type="date"
            required
          />
        </div>
        
        <div class="form-group">
          <label for="dateOut">Data de Volta:</label>
          <input
            id="dateOut"
            v-model="form.dateOut"
            type="date"
            required
          />
        </div>
        
        
        <div class="modal-footer">
          <button type="button" @click="closeModal" class="btn-cancel">
            Cancelar
          </button>
          <button type="submit" class="btn-submit" :disabled="isSubmitting">
            {{ isSubmitting ? 'Cadastrando...' : 'Cadastrar' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, watch } from 'vue'

interface Props {
  isVisible: boolean
}

interface Emits {
  (e: 'close'): void
  (e: 'submit', data: FormData): void
}

interface FormData {
  name: string
  travel: string
  dateIn: string
  dateOut: string
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const isSubmitting = ref(false)
const form = reactive<FormData>({
  name: '',
  travel: '',
  dateIn: '',
  dateOut: ''
})

// Reset form when modal is closed
watch(() => props.isVisible, (newValue) => {
  if (!newValue) {
    resetForm()
  }
})

const resetForm = () => {
  form.name = ''
  form.travel = ''
  form.dateIn = ''
  form.dateOut = ''
  isSubmitting.value = false
}

const closeModal = () => {
  emit('close')
}

const validateForm = (): boolean => {
  // Verificar se as datas foram preenchidas
  if (!form.dateIn || !form.dateOut) {
    alert('Por favor, preencha as datas de ida e volta!')
    return false
  }
  
  // Converter strings de data para objetos Date para comparação
  const dateIn = new Date(form.dateIn)
  const dateOut = new Date(form.dateOut)
  
  // Verificar se as datas são válidas
  if (isNaN(dateIn.getTime()) || isNaN(dateOut.getTime())) {
    alert('Por favor, insira datas válidas!')
    return false
  }
  
  // Verificar se a data de ida não é maior que a data de volta
  if (dateIn.getTime() > dateOut.getTime()) {
    alert('A data de ida não pode ser maior que a data de volta!')
    return false
  }
  
  // Verificar se a data de ida não é no passado
  const today = new Date()
  today.setHours(0, 0, 0, 0) // Reset das horas para comparar apenas a data
  
  if (dateIn.getTime() < today.getTime()) {
    alert('A data de ida não pode ser no passado!')
    return false
  }
  
  return true
}

const handleSubmit = async () => {
  if (!validateForm()) return
  
  isSubmitting.value = true
  
  try {
    // Simular chamada da API
    await new Promise(resolve => setTimeout(resolve, 1500))

    emit('submit', { ...form })
    
    closeModal()
  } catch (error) {
    alert('Erro ao cadastrar viagem. Tente novamente.')
    console.error('Erro no cadastro:', error)
  } finally {
    isSubmitting.value = false
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 8px;
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #e5e7eb;
}

.modal-header h2 {
  margin: 0;
  color: #1f2937;
  font-size: 1.5rem;
}

.close-button {
  background: none;
  border: none;
  font-size: 2rem;
  cursor: pointer;
  color: #6b7280;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  transition: background-color 0.2s;
}

.close-button:hover {
  background-color: #f3f4f6;
  color: #374151;
}

.modal-body {
  padding: 1.5rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: #374151;
}

.form-group input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 1rem;
  transition: border-color 0.2s, box-shadow 0.2s;
}

.form-group input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.modal-footer {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
}

.btn-cancel,
.btn-submit {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 6px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s;
}

.btn-cancel {
  background-color: #f3f4f6;
  color: #374151;
}

.btn-cancel:hover {
  background-color: #e5e7eb;
}

.btn-submit {
  background-color: #3b82f6;
  color: white;
}

.btn-submit:hover:not(:disabled) {
  background-color: #2563eb;
}

.btn-submit:disabled {
  background-color: #9ca3af;
  cursor: not-allowed;
}

/* Responsividade */
@media (max-width: 640px) {
  .modal-content {
    width: 95%;
    margin: 1rem;
  }
  
  .modal-header,
  .modal-body {
    padding: 1rem;
  }
  
  .modal-footer {
    flex-direction: column;
  }
  
  .btn-cancel,
  .btn-submit {
    width: 100%;
  }
}
</style>