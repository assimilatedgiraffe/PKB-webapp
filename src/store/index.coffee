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
    userID: ""
    fbRef: {}


  mutations:
    setNotes: (state, payload) -> state.notes = payload
    setLoading: (state, payload) -> state.isLoading = payload
    setSelectedNote: (state, payload) -> state.selectedNote = payload
    setRootNode: (state, payload) -> state.rootNode = payload
    setUserID: (state, payload) ->
      state.userID = payload
      state.fbRef = firebase.database.ref('users/'+payload+'/notes')
    #TODO: setNoteText should be action not mutation
    setNoteText: (state, payload) ->
      console.log payload
      firebase.database.ref('users/'+state.userID+'/notes/'+payload.noteRef+'/text').set(payload.text)

  actions:  # async like DB accessing
    loadDatabase: ({commit, state}) ->
      commit("setLoading", true)
      firebase.database.ref('users/'+state.userID+'/notes/rootNode').once("value")
        .then (data) ->
          commit("setRootNode", data.val())
          firebase.database.ref('users/'+state.userID+'/notes').once("value")
            .then (data) ->
              commit("setNotes", data.val())
              # console.log state.rootNode
              firstRootChild = Object.keys(state.rootNode.children)[0]
              commit("setSelectedNote", state.rootNode.children[firstRootChild])
              commit("setLoading", false)
            .catch (error) ->
              console.log(error)
              commit("setLoading", true)

    watchDatabase: ({commit, state}) ->
      firebase.database.ref('users/'+state.userID+'/notes').on("value", (snapshot) ->
        commit("setNotes", snapshot.val()))

    signIn: ({commit, dispatch}, payload) ->
      firebase.auth.signInWithEmailAndPassword(payload.email, payload.password)
        .then (user) ->
          commit('setUserID', user.uid)
          dispatch('loadDatabase')
          dispatch('watchDatabase')
          # dispatch('generateTestData')
        .catch (error) -> console.log error

    createNote: ({commit, getters, state}, payload) ->
      # text, parent, [etc]
      firebase.database.ref('users/'+state.userID+'/notes').push(payload)
        .then (data) ->
          siblings = state.notes[payload.parent].children
          siblings.push(data.key)
          state.fbRef.child(payload.parent).child('children').set(siblings)
        .catch (error) ->
          console.log(error)

    deleteNote: ({state}, payload) ->
      parentRef = state.notes[payload].parent
      state.fbRef.child(payload).remove()
        .then () ->
          siblings = state.notes[parentRef].children.filter (e) -> e != payload
          state.fbRef.child(parentRef).child('children').set(siblings)
        .catch (error) ->
          console.log(error)

    generateTestData: ({commit, getters, state}) ->
      console.log "generateTestData"
      generateChildren = (parent, depth) ->
        if depth == 0
          return
        childRefs = []
        for x in [1..3]
          do ->
            firebase.database.ref('users/'+state.userID+'/notes').push({
              text: "test note " + depth + " - " + x
              parent: parent
              })
              .then (data) ->
                childRefs.push(data.key)
                generateChildren(data.key, depth - 1)
              .catch (error) ->
                console.log(error)
        sendChildRefs = -> state.fbRef.child(parent).child('children').set(childRefs)
        setTimeout(sendChildRefs, 2000)
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
