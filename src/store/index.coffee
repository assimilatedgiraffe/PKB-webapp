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
    user: null
    userID: ""
    fbRef: {}


  mutations: # $store.commit('setX', {param:value})
    setNotes: (state, payload) -> state.notes = payload
    setLoading: (state, payload) -> state.isLoading = payload
    setSelectedNote: (state, payload) -> state.selectedNote = payload
    setRootNode: (state, payload) -> state.rootNode = payload
    setUser: (state, user) ->
      state.user = user
      state.userID = user.uid
      state.fbRef = firebase.database.ref('users/'+user.uid+'/notes')

  actions:  # async like DB access Toki Pona, ing - $store.dispatch('action', {param:value})
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

    signIn: ({commit, state, dispatch}, user) ->
      # firebase.auth.signInWithEmailAndPassword(payload.email, payload.password)
      # .then (user) ->
      console.log user
      commit('setUser', user)
      #check if anonymous (demo mode)
      if user.isAnonymous == true
        console.log "demo mode"
        firebase.database.ref('demoNotes').once('value')
        .then (data) ->
          state.fbRef.set(data.val())

      #check if new user
      state.fbRef.child("rootNode").once("value").then (data) ->
        if not data.val()?
          console.log "new user" # no rootNode means new user
          state.fbRef.push({
            parent: "rootNode"
            text: "Wecome to your Personal Knoledge Base"
            }).then (data) ->
              state.fbRef.child("rootNode").child("children").set([data.key])
              dispatch('loadDatabase')
              dispatch('watchDatabase')
        else
          dispatch('loadDatabase')
          dispatch('watchDatabase')
              # dispatch('generateTestData')
              # .catch (error) -> console.log error

    signOut: ({commit, state, dispatch}) ->
      commit('setUser', null)

    createNote: ({commit, getters, state}, payload) ->
      # text, parent, [etc]
      firebase.database.ref('users/'+state.userID+'/notes').push(payload)
        .then (data) ->
          siblings = state.notes[payload.parent].children
          siblings ?= []
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

    setNoteText: ({state}, payload) ->
      # console.log payload
      state.fbRef.child(payload.noteRef).child('text').set(payload.text)

    setNoteChildren: ({state}, payload) ->
      # console.log payload
      if payload == []
        state.fbRef.child(payload.noteRef).child('children').remove()
      else
        state.fbRef.child(payload.noteRef).child('children').set(payload.children)

    setNoteParent: ({state}, payload) ->
      # console.log payload
      state.fbRef.child(payload.noteRef).child('parent').set(payload.parentRef)

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
    user: (state) -> state.user
    isLoading: (state) -> state.isLoading
    selectedNote: (state) -> state.selectedNote
    # return dict of {ref: note object} from list of refs
    refListToNotes: (state) -> (payload) ->
      # console.log payload
      return {} if !payload
      notes = {}
      for noteRef in payload
        do (noteRef) =>
          notes[noteRef] = state.notes[noteRef]
      return notes
    # get elders of currently selected note
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
    # get siblings of currently selected note
    selectedSiblings: (state) ->
      if (not state.isLoading) and state.notes[state.selectedNote]?
        parent = state.notes[state.selectedNote].parent
        siblings = {}
        # for noteRef in
        #   do (noteRef) =>
        #     siblings[noteRef] = state.notes[noteRef]
        return state.notes[parent].children
    # get children of currently selected note
    selectedChildren: (state, getters) ->
      children = state.notes[state.selectedNote]?.children
      if state.isLoading or not children?
        return []
      else
        return Object.values(children)
    # rootNode: (state) -> state.rootNode
)
