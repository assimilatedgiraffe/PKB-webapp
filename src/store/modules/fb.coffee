import firebase from '../firebase.js'

export default {
  state:
    fbRef: {}

  mutations:
    setFbRef: (state, payload) -> state.fbRef = payload

  actions:
    loadDemoNotes: ({state}) ->
      commit("setLoading", true)
      firebase.database.ref('demoNotes').once('value')
      .then (data) ->
        state.fbRef.set(data.val())

    loadNewUserNotes: ({state}) ->
      state.fbRef.push({
        parent: "rootNode"
        text: "Wecome to your Personal Knowledge Base"
        }).then (data) ->
          state.fbRef.child("rootNode").child("children").set([data.key])

    loadDatabase: ({commit, state, dispatch}) ->
      commit("setLoading", true)
      #check if new user, no rootNode means new user
      state.fbRef.child('rootNode').once("value")
      .then (data) ->
        if not data.val()?
          console.log "new user"
          dispatch('loadNewUserNotes').then(dispatch('watchDatabase'))
        else
          dispatch('watchDatabase')
      .catch (error) ->
        console.log(error)
        commit("setLoading", true)

    watchDatabase: ({commit, state, dispatch}) ->
      state.fbRef.once('value').then (data) ->
        commit('setNotes', data.val())
        dispatch('loadUI')
      state.fbRef.on("value", (snapshot) ->
        commit("setNotes", snapshot.val()))

    createNote: ({commit, getters, state}, newNote) ->
      # newNote = {text, parent, [etc]}
      console.log newNote
      # commit('setBusy', true)
      state.fbRef.push(newNote)
        .then (data) ->
          siblings = getters.siblings(newNote)
          siblings ?= []
          siblings.push(data.key)
          state.fbRef.child(newNote.parent).child('children').set(siblings)
          # .then(commit('setBusy', false))
        .catch (error) ->
          console.log(error)
          # commit('setBusy', false)

    deleteNote: ({state, getters, dispatch}, noteRef) ->
      note = getters.note(noteRef)
      if note.children?
        dispatch('deleteNote', child) for child in note.children
      parentRef = note.parent
      siblings = getters.siblings(note).filter (e) -> e != noteRef
      state.fbRef.child(parentRef).child('children').set(siblings)
        .then () ->
          state.fbRef.child(noteRef).remove()
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

}
