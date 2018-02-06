import Vue from 'vue'
import App from './App'
import router from './router'
import Vuetify from 'vuetify'
import 'vuetify/dist/vuetify.min.css'
import 'mdi/css/materialdesignicons.min.css'
import {store} from './store/index.coffee'
import VueAnalytics from 'vue-analytics'
require('offline-plugin/runtime').install();

Vue.use(VueAnalytics, {
  id: 'UA-113150419-2',
  router
})
Vue.use(Vuetify, { theme: {
  primary: '#00695C',
  secondary: '#263238'
  // accent: '#82B1FF',
  // error: '#FF5252',
  // info: '#2196F3',
  // success: '#4CAF50',
  // warning: '#FFC107'
}})

Vue.config.productionTip = false

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  render: h => h(App)
})
