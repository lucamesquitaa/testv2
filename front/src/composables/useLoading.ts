import { ref, computed } from 'vue'

interface LoadingState {
  isLoading: boolean
  message?: string
  overlay?: boolean
}

const loadingState = ref<LoadingState>({
  isLoading: false,
  message: '',
  overlay: true
})

const loadingStack = ref<string[]>([])

export function useLoading() {
  const isLoading = computed(() => loadingState.value.isLoading)
  const message = computed(() => loadingState.value.message)
  const overlay = computed(() => loadingState.value.overlay)

  const startLoading = (options?: {
    message?: string
    overlay?: boolean
    id?: string
  }) => {
    const id = options?.id || `loading-${Date.now()}`
    loadingStack.value.push(id)
    
    loadingState.value = {
      isLoading: true,
      message: options?.message || '',
      overlay: options?.overlay ?? true
    }

    return id
  }

  const stopLoading = (id?: string) => {
    if (id) {
      const index = loadingStack.value.indexOf(id)
      if (index > -1) {
        loadingStack.value.splice(index, 1)
      }
    } else {
      loadingStack.value.pop()
    }

    if (loadingStack.value.length === 0) {
      loadingState.value.isLoading = false
      loadingState.value.message = ''
    }
  }

  const stopAllLoading = () => {
    loadingStack.value = []
    loadingState.value.isLoading = false
    loadingState.value.message = ''
  }

  const withLoading = async <T>(
    asyncFn: () => Promise<T>,
    options?: {
      message?: string
      overlay?: boolean
    }
  ): Promise<T> => {
    const loadingId = startLoading(options)
    try {
      return await asyncFn()
    } finally {
      stopLoading(loadingId)
    }
  }

  return {
    isLoading,
    message,
    overlay,
    startLoading,
    stopLoading,
    stopAllLoading,
    withLoading
  }
}