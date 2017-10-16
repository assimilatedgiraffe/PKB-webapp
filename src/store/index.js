import Vue from 'vue'
import Vuex from 'vuex'
import firebase from './firebase.js'

Vue.use(Vuex)
Vue.use(firebase)

export const store = new Vuex.Store({
  state: {
    notes: {},
    isLoading: true
  },
  mutations: {
    setNotes: function (state, payload) {
      return state.notes = payload
    },
    setLoading: function (state, payload) {
      return state.isLoading = payload
    }
  },
  actions: { // async like DB accessing
    loadDatabase: function (context) {
      context.commit("setLoading", true)
      firebase.database.ref('notes/-KwJLK3mqJX_7SoVIaaL').once("value")
        .then((data) => {
          context.commit("setNotes", data.val())
          context.commit("setLoading", false)
        })
        .catch((error) => {
          console.log(error)
          context.commit("setLoading", true)
        })
    },
    watchDatabase: function (context) {
      firebase.database.ref('notes').on("value", function (snapshot) {
        context.commit("setNotes", snapshot.val())
      })
    }

  },
  getters: {
    notes(state) {
      return state.notes
    },
    isLoading(state) {
      return state.isLoading
    }

  }
})
