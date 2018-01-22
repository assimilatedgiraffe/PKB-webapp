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

    watchDatabase: ({commit, getters, state, dispatch}) ->
      state.fbRef.once('value').then (data) ->
        commit('setNotes', data.val())
        dispatch('loadUI')
      state.fbRef.on("value", (snapshot) ->
        if getters.isBusy
          return
        commit("setNotes", snapshot.val())
        # watch for delete from this or other clients
        if not getters.selectedNote?
          console.log "no note selected"
          if getters.isLoading
            return
          else if getters.dex[0] > 0
            commit('moveUp')
          else if state.selectedParentRef != "rootNode"
            commit('setSelectedParentRef', getters.selectedParent.parent)
            commit('moveLeft'))

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
      console.log payload
      if payload.children == []
        state.fbRef.child(payload.noteRef).child('children').remove()
      else
        state.fbRef.child(payload.noteRef).child('children').set(payload.children)

    setNoteParent: ({state}, payload) ->
      console.log payload
      state.fbRef.child(payload.noteRef).child('parent').set(payload.parentRef)

    shiftNote: ({commit, state, getters, dispatch}, key) ->
      if getters.isBusy
        return
      commit('setBusy', true)
      siblings = getters.selectedSiblings
      dex = getters.dex[0]
      switch key
        # shift selected note
          when 'j'
            console.log "shift down"
            if siblings.length > dex + 1
              siblings.splice(dex + 1, 0, siblings.splice(dex, 1)[0])
              dispatch('setNoteChildren', {
                noteRef: getters.selectedNote.parent
                children: siblings
                }).then =>
                  commit('moveDown')
                  commit('setBusy', false)
          when 'k'
            console.log "shift up"
            if dex > 0
              siblings.splice(dex - 1, 0, siblings.splice(dex, 1)[0])
              dispatch('setNoteChildren', {
                noteRef: getters.selectedNote.parent
                children: siblings
                }).then =>
                  commit('moveUp')
                  commit('setBusy', false)
          when 'h'
            console.log "shift left"
            parentRef = getters.selectedNote.parent
            if parentRef != "rootNode"
              grandParentRef = getters.selectedParent.parent
              elders = getters.selectedElders
              selected = getters.selectedNoteRef
              console.log siblings, elders
              elders.push(siblings.splice(dex, 1)[0])
              console.log siblings, elders
              dispatch('setNoteChildren', {
                noteRef: parentRef
                children: siblings })
              .then => dispatch('setNoteChildren', {
                noteRef: grandParentRef
                children: elders })
              .then => dispatch('setNoteParent', {
                noteRef: selected
                parentRef: grandParentRef })
              .then =>
                  # this.$store.commit('setSelectedNote', this.selectedNote)
                  # this.selectedNoteIndexs.shift()
                  commit('setSelectedParentRef', grandParentRef)
                  commit('moveLeft')
                  commit('setBusy', false)
                  # this.selectedNoteIndexs[0] = this.selectedSiblings.length - 1
          when 'l'
            console.log "shift right"
            # make child of note above
            if dex > 0
              newParentRef = siblings[dex - 1]
              newParent = getters.note(newParentRef)
              newParent.children ?= []
              console.log newParentRef, newParent, siblings
              noteToShift = siblings.splice(dex, 1)[0]
              newParent.children.push(noteToShift)
              console.log newParent.children, siblings
              dispatch('setNoteChildren', {
                noteRef: getters.selectedNote.parent
                children: siblings})
              .then => dispatch('setNoteChildren', {
                noteRef: newParentRef
                children: newParent.children})
              .then => dispatch('setNoteParent', {
                noteRef: noteToShift
                parentRef: newParentRef})
              .then =>
                commit('setSelectedParentRef', newParentRef)
                commit('moveRight')
                commit('setBusy', false)


}
