export default {
  state:
    isLoading: true
    # selectedNoteRef: ""
    isBusy: false #waiting for firebase
    selectedParentRef: ""
    dex: [0] #selected note indexes, stack from beginning of array using unshift()/shift()

  mutations:
    setLoading: (state, payload) -> state.isLoading = payload
    setBusy: (state, payload) -> state.isBusy = payload
    setSelectedParentRef: (state, payload) -> state.selectedParentRef = payload
    #!! need to use splice on array so vue can detect change !!
    moveDown: (state) -> state.dex.splice(0, 1, state.dex[0] + 1)
    moveUp: (state) -> state.dex.splice(0, 1, state.dex[0] - 1)
    moveRight: (state) -> state.dex.unshift(0)
    moveLeft: (state) -> state.dex.shift()

  actions:
    loadUI: ({commit, state, getters}) ->
      commit("setSelectedParentRef", 'rootNode')
      commit("setLoading", false)

    navigate: ({commit, state, getters, dispatch}, key) ->
      if state.isBusy
        return
      switch key
      # vim style navigaion
        when "j"
          console.log "down"
          if getters.selectedSiblings.length > state.dex[0] + 1
            commit('moveDown')
          else #create new empty note if none exists
            commit('setBusy', true)
            dispatch('createNote', {text:"", parent:getters.selectedNote.parent})
            .then =>
              commit('moveDown')
              commit('setBusy', false)
        when 'k'
          console.log "up"
          if state.dex[0] > 0
            commit('moveUp')
        when 'h'
          console.log "left"
          if state.selectedParentRef != "rootNode"
            commit('setSelectedParentRef', getters.selectedParent.parent)
            commit('moveLeft')
        when 'l'
          console.log "right"
          if getters.selectedNote.children?
            commit("setSelectedParentRef", getters.selectedNoteRef)
            commit('moveRight')
          else # create new child note if none exist
            commit('setBusy', true)
            dispatch('createNote', {text:"", parent:getters.selectedNoteRef})
            .then =>
              commit("setSelectedParentRef", getters.selectedNoteRef)
              commit('moveRight')
              commit('setBusy', false)

  getters:
    isLoading: (state) -> state.isLoading
    dex: (state) -> state.dex
    selectedNote: (state, getters) -> getters.note(getters.selectedSiblings[state.dex[0]])
    selectedNoteRef: (state, getters) -> getters.selectedSiblings[state.dex[0]]
    selectedSiblings: (state, getters) ->
      # siblings = getters.note(state.selectedParentRef)?.children
      siblings = getters.selectedParent?.children
      siblings ?= []
      return siblings
    selectedElders: (state, getters) ->
      elders = getters.siblings(getters.selectedParent)
      elders ?= []
      return elders
    selectedParent: (state, getters) -> getters.note(state.selectedParentRef)
    selectedChildren: (state, getters) ->
      children = getters.selectedNote?.children
      if getters.isLoading or not children?
        return []
      else
        return children


}
