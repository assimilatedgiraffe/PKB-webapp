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
    setNoteText: (state, payload) ->
      console.log payload
      firebase.database.ref('notes/' + payload.noteRef + '/text').set(payload.text)

  actions:  # async like DB accessing
    loadDatabase: ({commit, state}) ->
      commit("setLoading", true)
      firebase.database.ref('notes/rootNode').once("value")
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
      console.log payload
      firebase.database.ref('notes').push(payload)
        .then (data) ->
          firebase.database.ref('notes/' + payload.parent + '/children')
            .push(data.key)
        .catch (error) ->
          console.log(error)



    generateTestData: ({commit, getters}) ->
      console.log "generateTestData"
      generateChildren = (parent, depth) ->
        if depth == 0
          return
        for x in [1..3]
          do ->
            firebase.database.ref('notes').push({
              text: "test note " + depth + " - " + x
              parent: parent
              })
              .then (data) ->
                firebase.database.ref('notes/' + parent + '/children')
                  .push(data.key)
                generateChildren(data.key, depth - 1)
              .catch (error) ->
                console.log(error)
      generateChildren("rootNode", 3)
  getters:
    notes: (state) -> state.notes
    isLoading: (state) -> state.isLoading
    selectedNote: (state) -> state.selectedNote
    refListToNotes: (state) -> (payload) ->
      # console.log payload
      notes = {}
      for noteRef in payload
        do (noteRef) =>
          notes[noteRef] = state.notes[noteRef]
      return notes
    selectedElders: (state) ->
      if state.isLoading
        return []
      else
        parentRef = state.notes[state.selectedNote].parent
        if parentRef == "rootNode"
          return []
        else
          grandParentRef = state.notes[parentRef].parent
          elders = state.notes[grandParentRef].children
          return Object.values(elders)
    selectedSiblings: (state) ->
      if (not state.isLoading) and state.notes[state.selectedNote]?
        parent = state.notes[state.selectedNote].parent
        siblings = {}
        # for noteRef in
        #   do (noteRef) =>
        #     siblings[noteRef] = state.notes[noteRef]
        return Object.values(state.notes[parent].children)
    selectedChildren: (state, getters) ->
      children = state.notes[state.selectedNote]?.children
      if state.isLoading or not children?
        return []
      else
        return Object.values(children)
    # rootNode: (state) -> state.rootNode
)
