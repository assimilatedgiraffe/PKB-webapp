// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
// import './firebase'
import Vue from 'vue'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'
import locale from 'element-ui/lib/locale/lang/en'
// import VueFire from 'vuefire'
import App from './App'
import router from './router'
import {store} from './store/index.coffee'
import VueHotkey from 'v-hotkey'
import VueAnalytics from 'vue-analytics'
import 'vue-awesome/icons/github'
import 'vue-awesome/icons/sign-out'
import Icon from 'vue-awesome/components/Icon'

Vue.config.productionTip = false
Vue.use(ElementUI, { locale })
// Vue.use(VueFire)
Vue.use(VueHotkey)
Vue.use(VueAnalytics, {
  id: 'UA-113150419-2',
  router
})
Vue.component('icon', Icon)

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  template: '<App/>',
  components: { App }
})
