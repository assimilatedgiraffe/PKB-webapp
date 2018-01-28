import firebase from '../firebase.js'

export default {
  state:
    fbRef: {}

  mutations:
    setFbRef: (state, payload) -> state.fbRef = payload

  actions:
    loadDemoNotes: ({state, commit}) ->
      commit("setLoading", true)
      firebase.database.ref('demoNotes').once('value')
      .then (data) ->
        state.fbRef.set(data.val())

    loadNewUserNotes: ({state}) ->
      state.fbRef.push({
        parent: "rootNode"
        text: "Welcome to your Personal Knowledge Base"
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

    watchDatabase: ({commit, getters, state, dispatch}) ->
      state.fbRef.once('value').then (data) ->
        commit('setNotes', data.val())
        dispatch('loadUI')
      state.fbRef.on "value", (snapshot) ->
        # watch for delete from this or other clients
        if not snapshot.val()[getters.selectedNoteRef]?
          if not getters.isLoading #and not getters.isBusy
            console.log "selected note missing"
            if getters.dex > 0
              commit 'setSelectedNoteRef', getters.selectedSiblings[getters.dex - 1]
            else if getters.selectedParentRef != "rootNode"
              commit 'setSelectedNoteRef', getters.selectedParentRef
        commit "setNotes", snapshot.val()
      # watch connection
      connectedRef = firebase.database.ref(".info/connected")
      connectedRef.on "value", (snap) ->
        if (snap.val() == true)
          commit("setConnected", true)
        else
          commit("setConnected", false)

    createNote: ({commit, getters, state}, newNote) ->
      # newNote = {text, parent, [etc]}
      throw 'offline' if getters.isConnected == false
      # commit('setBusy', true)
      console.log "newNote", newNote
      state.fbRef.push(newNote)
        .then (data) ->
          siblings = getters.siblings(newNote)
          siblings ?= []
          siblings.push(data.key)
          state.fbRef.child(newNote.parent).child('children').set(siblings)
          # .then(commit('setBusy', false))
        .catch (error) ->
          console.log error, "cant create note"
          commit('setBusy', false)

    deleteNote: ({state, getters, dispatch, commit}, {noteRef, j}) ->
      # j is recursive counter to stop setBusy getting set to false too soon
      if getters.selectedParentRef == 'rootNode' and getters.dex == 0
        commit 'setError', 'Error: Cannot delete root note'
        return

      commit('setBusy', true)
      note = getters.note(noteRef)
      noteDelete = =>
        parentRef = note.parent
        siblings = getters.siblings(note).filter (e) -> e != noteRef
        state.fbRef.child(noteRef).remove()
        .then () ->
          state.fbRef.child(parentRef).child('children').set(siblings)
          if j == 0 then commit('setBusy', false)
        .catch (error) ->
          console.log(error)
          if j == 0 then commit('setBusy', false)

      if note.children?
        promises = (dispatch('deleteNote', {noteRef:child, j:j+2}) for child in note.children)
        console.log promises, noteDelete
        Promise.all(promises).then =>
          noteDelete()
      else noteDelete()

    setNoteText: ({state, getters}, payload) ->
      console.log "setNoteText", payload
      throw 'offline' if getters.isConnected == false
      state.fbRef.child(payload.noteRef).child('text').set(payload.text)

    setNoteChildren: ({state, getters}, payload) ->
      throw 'offline' if getters.isConnected == false
      console.log payload
      if payload.children == []
        state.fbRef.child(payload.noteRef).child('children').remove()
      else
        state.fbRef.child(payload.noteRef).child('children').set(payload.children)

    setNoteParent: ({state, getters, dispatch}, payload) ->
      throw 'offline' if getters.isConnected == false
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

      dispatch('setNoteChildren', {
        noteRef: currentParentRef
        children: oldSiblings})
      .then => dispatch('setNoteChildren', {
        noteRef: newParentRef
        children: newParent.children})
      .then =>
        state.fbRef.child(payload.noteRef).child('parent').set(payload.parentRef)
      # .then => commit('setBusy', false)

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


}
