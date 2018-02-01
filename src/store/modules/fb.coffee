import firebase from '../firebase.js'

export default {
  state:
    fbRef: {} #realtime database
    fsRef: {} #firestore database

  mutations:
    setFbRef: (state, payload) -> state.fbRef = payload
    setFsRef: (state, payload) -> state.fsRef = payload

  actions:
    initDatabase: ({state, commit, getters}) ->
      console.log "initDatabase"
      firebase.firebase.firestore().enablePersistence().then =>
          # Initialize Cloud Firestore through firebase
        firestore = firebase.firebase.firestore()
        commit('setFsRef', firestore.collection("users").doc(getters.userID).collection("notes"))
      .catch (err) ->
        if err.code == 'failed-precondition'
          console.log err
          #     // Multiple tabs open, persistence can only be enabled
          #     // in one tab at a a time.
          #     // ...
        else if err.code == 'unimplemented'
          console.log err
          #     // The current browser does not support all of the
          #     // features required to enable persistence
          #     // ...

    loadDemoNotes: ({state, commit}) ->
      commit("setLoading", true)
      firebase.database.ref('demoNotes').once('value')
      .then (data) ->
        state.fsRef.doc(key).set(value) for own key, value of data.val()

    # loadNewUserNotes: ({state}) ->
    #   state.fbRef.push({
    #     parent: "rootNode"
    #     text: "Welcome to your Personal Knowledge Base"
    #     }).then (data) ->
    #       state.fbRef.child("rootNode").child("children").set([data.key])

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
      state.fsRef.get().then (snapshot) ->
        notes = {}
        snapshot.forEach (doc) ->
          notes[doc.id] = doc.data()
        commit('setNotes', notes)
        dispatch('loadUI')
      state.fsRef.onSnapshot (snapshot) ->
        snapshot.docChanges.forEach (change) ->
          if change.type == "added"
            commit('addLocalNote', {id:change.doc.id, data:change.doc.data()})
          if change.type == "modified"
            commit('modifyLocalNote', {id:change.doc.id, data:change.doc.data()})
          if change.type == "removed"
             # watch for selected note delete from this or other clients
            if change.doc.id == getters.selectedNoteRef and not getters.isLoading
              console.log "selected note missing"
              if getters.dex > 0
                commit 'setSelectedNoteRef', getters.selectedSiblings[getters.dex - 1]
              else if getters.selectedParentRef != "rootNode"
                commit 'setSelectedNoteRef', getters.selectedParentRef
            commit('removeLocalNote', change.doc.id)
      # state.fbRef.on "value", (snapshot) ->
      #   # watch for delete from this or other clients
      #   if not snapshot.val()[getters.selectedNoteRef]?
      #     if not getters.isLoading #and not getters.isBusy
      #       console.log "selected note missing"
      #       if getters.dex > 0
      #         commit 'setSelectedNoteRef', getters.selectedSiblings[getters.dex - 1]
      #       else if getters.selectedParentRef != "rootNode"
      #         commit 'setSelectedNoteRef', getters.selectedParentRef
      #   commit "setNotes", snapshot.val()
      # watch connection
      connectedRef = firebase.database.ref(".info/connected")
      connectedRef.on "value", (snap) ->
        if (snap.val() == true)
          commit("setConnected", true)
        else
          commit("setConnected", false)

    createNote: ({commit, getters, state}, newNote) ->
      # newNote = {text, parent, [etc]}
      # throw 'offline' if getters.isConnected == false
      # commit('setBusy', true)
      console.log "newNote", newNote
      # batch = firebase.firebase.firestore().batch()
      state.fsRef.add(newNote)
      .then (doc) ->
        siblings = getters.siblings(newNote)
        siblings ?= []
        siblings.push(doc.id)
        state.fsRef.doc(newNote.parent).update({children:siblings})
      # state.fbRef.push(newNote)
      #   .then (data) ->
      #     siblings = getters.siblings(newNote)
      #     siblings ?= []
      #     siblings.push(data.key)
      #     state.fbRef.child(newNote.parent).child('children').set(siblings)
      #     # .then(commit('setBusy', false))
      #   .catch (error) ->
      #     console.log error, "cant create note"
      #     commit('setBusy', false)

    deleteNote: ({state, getters, dispatch, commit}, {noteRef, j}) ->
      if getters.selectedParentRef == 'rootNode' and getters.dex == 0
        commit 'setError', 'Error: Cannot delete first note'
        return
      commit('setBusy', true)
      batch = firebase.firebase.firestore().batch()
      # recursively delete note children
      noteDelete = (refToDelete) ->
        note = getters.note(refToDelete)
        if note.children?
          noteDelete(child) for child in note.children
        siblings = getters.siblings(note).filter (e) -> e != refToDelete
        batch.update(state.fsRef.doc(note.parent), {children:siblings})
        batch.delete(state.fsRef.doc(refToDelete))

      noteDelete(noteRef)
      batch.commit().then -> commit('setBusy', false)

    setNoteText: ({state, getters}, payload) ->
      console.log "setNoteText", payload
      # throw 'offline' if getters.isConnected == false
      # state.fbRef.child(payload.noteRef).child('text').set(payload.text)
      state.fsRef.doc(payload.noteRef).update({text:payload.text})

    setNoteChildren: ({state, getters}, payload) ->
      state.fsRef.doc(payload.noteRef).update({children:payload.children})
      # throw 'offline' if getters.isConnected == false
      # console.log payload
      # if payload.children == []
        # state.fbRef.child(payload.noteRef).child('children').remove()
      # else
        # state.fbRef.child(payload.noteRef).child('children').set(payload.children)

    setNoteParent: ({state, getters, dispatch}, payload) ->
      # throw 'offline' if getters.isConnected == false
      console.log payload

      currentParentRef = getters.note(payload.noteRef).parent
      oldSiblings = getters.note(currentParentRef).children

      newParentRef = payload.parentRef
      newParent = getters.note(newParentRef)
      newParent.children ?= []

      console.log newParent.children, oldSiblings
      oldSiblings = oldSiblings.filter((e) -> e != payload.noteRef)
      newParent.children.push(payload.noteRef)
      console.log newParent.children, oldSiblings
      
      batch = firebase.firebase.firestore().batch()
      batch.update(state.fsRef.doc(currentParentRef), {children:oldSiblings})
      batch.update(state.fsRef.doc(newParentRef), {children:newParent.children})
      batch.update(state.fsRef.doc(payload.noteRef), {parent:payload.parentRef})
      batch.commit()

    shiftNote: ({commit, state, getters, dispatch}, key) ->
      throw 'offline' if getters.isConnected == false
      if getters.isBusy
        return
      commit('setBusy', true)
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
                }).then =>
                  commit('setBusy', false)
            else commit('setBusy', false)
          when 'k', "ArrowUp"
            console.log "shift up"
            if dex > 0
              siblings.splice(dex - 1, 0, siblings.splice(dex, 1)[0])
              dispatch('setNoteChildren', {
                noteRef: getters.selectedNote.parent
                children: siblings
                }).then =>
                  commit('setBusy', false)
            else commit('setBusy', false)
          when 'h', "ArrowLeft"
            console.log "shift left"
            parentRef = getters.selectedNote.parent
            if parentRef != "rootNode"
              grandParentRef = getters.selectedParent.parent
              selected = getters.selectedNoteRef
              dispatch('setNoteParent', {
                noteRef: selected
                parentRef: grandParentRef })
              .then =>
                  # commit('setSelectedParentRef', grandParentRef)
                  # commit('moveLeft')
                  commit('setBusy', false)
                  # this.selectedNoteIndexs[0] = this.selectedSiblings.length - 1
            else commit('setBusy', false)
          when 'l', "ArrowRight"
            console.log "shift right"
            # make child of note above
            if dex > 0
              newParentRef = siblings[dex - 1]
              dispatch('setNoteParent', {
                noteRef: getters.selectedNoteRef
                parentRef: newParentRef})
              .then =>
                # commit('setSelectedParentRef', newParentRef)
                # commit('moveRight')
                commit('setBusy', false)
            else commit('setBusy', false)
          else
            commit('setBusy', false)


}
