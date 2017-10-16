import Vue from 'vue'
import Vuex from 'vuex'
import firebase from './firebase.js'

Vue.use(Vuex)
Vue.use(firebase)

export store = new Vuex.Store(
  state:
    notes: {}
    isLoading: true

  mutations:
    setNotes: (state, payload) -> state.notes = payload
    setLoading: (state, payload) -> state.isLoading = payload

  actions:  # async like DB accessing
    loadDatabase: (context) ->
      context.commit("setLoading", true)
      firebase.database.ref('notes/-KwJLK3mqJX_7SoVIaaL').once("value")
        .then (data) ->
          context.commit("setNotes", data.val())
          context.commit("setLoading", false)
        .catch (error) ->
          console.log(error)
          context.commit("setLoading", true)
    #
    # watchDatabase: (context) ->
    #   firebase.database.ref('notes').on("value", (snapshot) ->
    #     context.commit("setNotes", snapshot.val())

  getters:
    notes: (state) -> state.notes
    isLoading: (state) -> return state.isLoading
)
