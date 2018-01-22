// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
// import './firebase'
import Vue from 'vue'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-default/index.css'
// import VueFire from 'vuefire'
import App from './App'
import router from './router'
import {store} from './store/index.coffee'
import VueHotkey from 'v-hotkey'

Vue.config.productionTip = false
Vue.use(ElementUI)
// Vue.use(VueFire)
Vue.use(VueHotkey)

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  template: '<App/>',
  components: { App }
})
