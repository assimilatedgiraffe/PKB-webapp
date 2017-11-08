import Vue from 'vue'
import Vuex from 'vuex'
import firebase from './firebase.js'

Vue.use(Vuex)
Vue.use(firebase)

export store = new Vuex.Store(
  state:
    rootNode: {}
    notes: {}
    ###
    text: ''
    parent: ref
    children: [...refs]
    ###
    selectedNote: {}
    isLoading: true
    test: "ghjgh"


  mutations:
    setNotes: (state, payload) -> state.notes = payload
    setLoading: (state, payload) -> state.isLoading = payload
    setSelectedNote: (state, payload) -> state.selectedNote = payload
    setRootNode: (state, payload) -> state.rootNode = payload

  actions:  # async like DB accessing
    loadDatabase: ({commit, state}) ->
      commit("setLoading", true)
      firebase.database.ref('rootNode').once("value")
        .then (data) ->
          commit("setRootNode", data.val())
          firebase.database.ref('notes').once("value")
            .then (data) ->
              commit("setNotes", data.val())
              # console.log state.rootNode
              firstRootChild = Object.keys(state.rootNode.children)[0]
              commit("setSelectedNote", state.rootNode.children[firstRootChild])
              commit("setLoading", false)
            .catch (error) ->
              console.log(error)
              commit("setLoading", true)

    watchDatabase: (context) ->
      firebase.database.ref('notes').on("value", (snapshot) ->
        context.commit("setNotes", snapshot.val()))

    createNote: ({commit, getters}, payload) ->
      # text, parent, [etc]
      firebase.database.ref('notes').push(note)
        .then (data) ->
          firebase.database.ref('notes/' + payload.parent.key + '/children')
            .push(data.key)
        .catch (error) ->
          console.log(error)

    generateTestData: ({commit, getters}) ->
      console.log "generateTestData"
      for x in [1..3]
        do ->
          firebase.database.ref('notes').push({text: "test note " + x})
            .then (data) ->
              firebase.database.ref('rootNode/children')
                .push(data.key)
            .catch (error) ->
              console.log(error)

  getters:
    notes: (state) -> state.notes
    isLoading: (state) -> state.isLoading
    selectedNote: (state) -> state.selectedNote
    # selectedSiblings: (state) -> state.notes[state.selectedNote.parent].children
    # rootNode: (state) -> state.rootNode
)
