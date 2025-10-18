import './assets/main.css'

import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

import { OhVueIcon, addIcons } from "oh-vue-icons"
import { FaPlaneDeparture, BiTrashFill } from "oh-vue-icons/icons"

addIcons(FaPlaneDeparture, BiTrashFill)

const app = createApp(App)

app.component("v-icon", OhVueIcon)
app.use(router)

app.mount('#app')
