import Vue from 'vue'
import Vuex from 'vuex'
import firebase from 'firebase'

import user from './modules/user.coffee'
import ui from './modules/ui.coffee'
import fb from './modules/fb.coffee'
import notes from './modules/notes.coffee'

Vue.use(Vuex)
Vue.use(firebase)

export store = new Vuex.Store(
  modules: {
    user
    fb
    notes
    ui
  }

  # strict: process.env.NODE_ENV != 'production'
  # state:


  # mutations: # $store.commit('setX', {param:value})

  # actions:  # async like DB access Toki Pona, ing - $store.dispatch('action', {param:value})



)
