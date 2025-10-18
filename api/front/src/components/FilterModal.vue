<template>
  <div v-if="isVisible" class="modal-overlay" @click="handleOverlayClick">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h3>Filtrar por Status</h3>
        <button @click="closeModal" class="close-button">&times;</button>
      </div>
      
      <div class="modal-body">
        <form @submit.prevent="submitFilter">
          <div class="form-group">
            <label for="status">Status da Viagem:</label>
            <select v-model="selectedStatus" id="status" class="form-select">
              <option value="">Todos os Status</option>
              <option value="Pendente">Pendente</option>
              <option value="Aprovada">Aprovada</option>
              <option value="Cancelada">Cancelada</option>
            </select>
          </div>
          
          <div class="modal-actions">
            <button type="button" @click="clearFilter" class="btn-secondary">
              Limpar Filtro
            </button>
            <button type="submit" class="btn-primary">
              Aplicar Filtro
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'

interface Props {
  isVisible: boolean
}

interface FilterData {
  travel: string
}

const props = defineProps<Props>()
const emit = defineEmits<{
  close: []
  submit: [filterData: FilterData]
}>()

const selectedStatus = ref<string>('')

// Resetar o filtro quando o modal for fechado
watch(() => props.isVisible, (newValue) => {
  if (!newValue) {
    selectedStatus.value = ''
  }
})

const closeModal = () => {
  emit('close')
}

const handleOverlayClick = () => {
  closeModal()
}

const submitFilter = () => {
  const filterData: FilterData = {
    travel: selectedStatus.value
  }
  emit('submit', filterData)
}

const clearFilter = () => {
  selectedStatus.value = ''
  const filterData: FilterData = {
    travel: ''
  }
  emit('submit', filterData)
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  max-width: 400px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #e5e5e5;
}

.modal-header h3 {
  margin: 0;
  color: #333;
  font-size: 1.25rem;
}

.close-button {
  background: none;
  border: none;
  font-size: 1.5rem;
  color: #666;
  cursor: pointer;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  justify-content: center;
  align-items: center;
  border-radius: 50%;
  transition: background-color 0.2s;
}

.close-button:hover {
  background-color: #f5f5f5;
  color: #333;
}

.modal-body {
  padding: 20px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #333;
}

.form-select {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  background-color: white;
  transition: border-color 0.2s;
}

.form-select:focus {
  outline: none;
  border-color: #007bff;
  box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1);
}

.modal-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
  margin-top: 20px;
}

.btn-primary,
.btn-secondary {
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.btn-primary {
  background-color: #007bff;
  color: white;
}

.btn-primary:hover {
  background-color: #0056b3;
}

.btn-secondary {
  background-color: #6c757d;
  color: white;
}

.btn-secondary:hover {
  background-color: #545b62;
}

/* Responsividade */
@media (max-width: 480px) {
  .modal-content {
    width: 95%;
    margin: 10px;
  }
  
  .modal-actions {
    flex-direction: column;
  }
  
  .btn-primary,
  .btn-secondary {
    width: 100%;
  }
}
</style>