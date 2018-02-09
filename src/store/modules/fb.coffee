import firebase from '../firebase.js'
import uuidv1 from 'uuid/v1'

export default {
  state:
    fsRef: {} #firestore database

  mutations:
    setFsRef: (state, payload) -> state.fsRef = payload

  actions:
    initDatabase: ({state, commit, getters}) ->
      console.log "initDatabase"
      setFirestoreReference = =>
        firestore = firebase.firebase.firestore()
        commit('setFsRef', firestore.collection("users").doc(getters.userID).collection("notes"))

      try
        firebase.firebase.firestore().enablePersistence().then =>
          # Initialize Cloud Firestore through firebase
          setFirestoreReference()
      catch err
        if err.code == 'failed-precondition'
          console.log err
          #     // Multiple tabs open, persistence can only be enabled
          #     // in one tab at a a time.
          #     // ...
          setFirestoreReference()
        else if err.code == 'unimplemented'
          console.log err
          #     // The current browser does not support all of the
          #     // features required to enable persistence
          #     // ...
          setFirestoreReference()

    loadDemoNotes: ({state, commit}) ->
      commit("setLoading", true)
      firebase.database.ref('demoNotes').once('value')
      .then (data) ->
        state.fsRef.doc(key).set(value) for own key, value of data.val()

    loadDatabase: ({commit, state, dispatch}) ->
      commit("setLoading", true)
      #check if new user, no rootNode means new user
      state.fsRef.doc('rootNode').get()
      .then (doc) ->
        if not doc.exists
          console.log "new user"
          dispatch('loadDemoNotes').then(dispatch('watchDatabase'))
        else
          dispatch('watchDatabase')
      .catch (error) ->
        console.log(error)
        commit("setLoading", true)

    watchDatabase: ({commit, getters, state, dispatch}) ->
      state.fsRef.onSnapshot (snapshot) ->
        # if snapshot.metadata.fromCache
        snapshot.docChanges.forEach (change) ->
          # console.log "fb change", change
          if change.type == "added"
            # if getters.isLoading then return
            commit('addLocalNote', {id:change.doc.id, data:change.doc.data()})
            if change.doc.id == "rootNode" then dispatch('loadUI')

          if change.type == "modified"
            commit('modifyLocalNote', {id:change.doc.id, data:change.doc.data()})

          if change.type == "removed"
             # watch for selected note delete from this or other clients
            if change.doc.id == getters.selectedNoteRef and not getters.isLoading
              console.log "selected note missing"
              commit "setSelectedNoteRef", getters.note('rootNode').children[0]
            commit('removeLocalNote', change.doc.id)

        # set busy to false after data received back from firebase to prevent
        # unstable state.
        commit 'setBusy', false

      # watch connection
      connectedRef = firebase.database.ref(".info/connected")
      connectedRef.on "value", (snap) ->
        if (snap.val() == true)
          commit("setConnected", true)
        else
          commit("setConnected", false)

    createNote: ({commit, getters, state}, newNote) ->
      # newNote = {text, parent, [etc]}
      # console.log "newNote", newNote
      commit('setBusy', true)
      newRef = uuidv1() # set uids manually as firestore.add() doesn't work with batch
      batch = firebase.firebase.firestore().batch()
      batch.set(state.fsRef.doc(newRef), newNote)

      siblings = getters.note(newNote.parent).children
      siblings ?= []
      siblings.push(newRef)
      batch.update(state.fsRef.doc(newNote.parent), {children:siblings})

      batch.commit()
      commit('addLocalNote', {id:newRef, data:newNote})
      commit 'setSelectedNoteRef', newRef

    deleteNote: ({state, getters, dispatch, commit}, noteRef) ->
      console.log "deleteNote", noteRef
      siblings = getters.siblingsByRef(noteRef)
      dex = siblings.indexOf(noteRef)
      parent = getters.note(noteRef).parent
      if parent == 'rootNode' and dex == 0
        commit 'setError', 'Error: Cannot delete first note'
        return

      commit('setBusy', true)
      batch = firebase.firebase.firestore().batch()
      # recursively delete note children
      noteDelete = (refToDelete) ->
        note = getters.note(refToDelete)
        if note.children?
          noteDelete(child) for child in note.children
        theseSiblings = getters.siblings(note).filter (e) -> e != refToDelete
        batch.update(state.fsRef.doc(note.parent), {children:theseSiblings})
        batch.delete(state.fsRef.doc(refToDelete))
      noteDelete(noteRef)

      if noteRef == getters.selectedNoteRef
        # set selected
        if dex > 0
          commit 'setSelectedNoteRef', siblings[dex - 1]
        else if parent != "rootNode"
          commit 'setSelectedNoteRef', parent
      batch.commit()

    setNoteText: ({state, getters}, payload) ->
      console.log "setNoteText", payload
      state.fsRef.doc(payload.noteRef).update({text:payload.text})

    setNoteChildren: ({commit, state, getters}, payload) ->
      commit 'setBusy', true
      state.fsRef.doc(payload.noteRef).update({children:payload.children})

    setNoteParent: ({commit, state, getters, dispatch}, payload) ->
      console.log payload
      #cant set note to be it's own child!
      if payload.noteRef == payload.parentRef then return
      commit 'setBusy', true

      currentParentRef = getters.note(payload.noteRef).parent
      oldSiblings = getters.note(currentParentRef).children

      newParentRef = payload.parentRef
      newParent = getters.note(newParentRef)
      newParent.children ?= []

      console.log newParent.children, oldSiblings
      oldSiblings = oldSiblings.filter((e) -> e != payload.noteRef)
      payload.index ?= 0
      newParent.children.splice(payload.index, 0, payload.noteRef)
      console.log newParent.children, oldSiblings

      batch = firebase.firebase.firestore().batch()
      batch.update(state.fsRef.doc(currentParentRef), {children:oldSiblings})
      batch.update(state.fsRef.doc(newParentRef), {children:newParent.children})
      batch.update(state.fsRef.doc(payload.noteRef), {parent:payload.parentRef})
      batch.commit()

    shiftNote: ({commit, state, getters, dispatch}, key) ->
      siblings = getters.selectedSiblings
      dex = getters.dex
      switch key
        # shift selected note
        when 'j', "ArrowDown"
          console.log "shift down"
          if siblings.length > dex + 1
            siblings.splice(dex + 1, 0, siblings.splice(dex, 1)[0])
            dispatch('setNoteChildren', {
              noteRef: getters.selectedNote.parent
              children: siblings
              })

        when 'k', "ArrowUp"
          console.log "shift up"
          if dex > 0
            siblings.splice(dex - 1, 0, siblings.splice(dex, 1)[0])
            dispatch('setNoteChildren', {
              noteRef: getters.selectedNote.parent
              children: siblings
              })

        when 'h', "ArrowLeft"
          console.log "shift left"
          parentRef = getters.selectedNote.parent
          if parentRef != "rootNode"
            grandParentRef = getters.selectedParent.parent
            selected = getters.selectedNoteRef
            dispatch('setNoteParent', {
              noteRef: selected
              parentRef: grandParentRef })

        when 'l', "ArrowRight"
          console.log "shift right"
          # make child of note above
          if dex > 0
            newParentRef = siblings[dex - 1]
            dispatch('setNoteParent', {
              noteRef: getters.selectedNoteRef
              parentRef: newParentRef})


}
