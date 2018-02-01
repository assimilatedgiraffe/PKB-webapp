# import VueScrollTo from 'vue-scrollto'
import scrollIntoViewIfNeeded from 'scroll-into-view-if-needed'

export default {
  state:
    isLoading: false
    isConnected: true #firebase connection
    isBusy: false #waiting for firebase
    selectedNoteRef: ""
    error: ""
    # history: [] # refs of selected parents
    # selectedParentRef: ""
    # dex: [0] #selected note indexes, stack from beginning of array using unshift()/shift()

  mutations:
    setLoading: (state, payload) -> state.isLoading = payload
    setConnected: (state, payload) -> state.isConnected = payload
    setBusy: (state, payload) -> state.isBusy = payload
    setError: (state, payload) -> state.error = payload
    setSelectedNoteRef: (state, payload) -> state.selectedNoteRef = payload
    # setSelectedParentRef: (state, payload) -> state.selectedParentRef = payload
    #!! need to use splice on array so vue can detect change !!
    # moveDown: (state) -> state.dex.splice(0, 1, state.dex[0] + 1)
    # moveUp: (state) -> state.dex.splice(0, 1, state.dex[0] - 1)
    # historyPop: (state) -> state.history.shift()
    # historyPush: (state, payload) -> state.history.unshift(payload)

  actions:
    loadUI: ({commit, state, getters}) ->
      commit "setSelectedNoteRef", getters.note('rootNode').children[0]
      commit("setLoading", false)

    navigate: ({commit, state, getters, dispatch}, key) ->
      if state.isBusy
        return
      switch key
      # vim style navigaion
        when "j", "ArrowDown"
          console.log "down"
          if getters.selectedSiblings.length > getters.dex + 1
            commit 'setSelectedNoteRef', getters.selectedSiblings[getters.dex + 1]
          else #create new empty note if none exists
            commit('setBusy', true)
            dispatch('createNote', {text:"", parent:getters.selectedParentRef})
            .then =>
              commit 'setSelectedNoteRef', getters.selectedSiblings[getters.dex + 1]
              commit('setBusy', false)

        when 'k', "ArrowUp"
          console.log "up"
          if getters.dex > 0
            commit 'setSelectedNoteRef', getters.selectedSiblings[getters.dex - 1]
        when 'h', "ArrowLeft"
          console.log "left"
          if getters.selectedParentRef != "rootNode"
            commit('setSelectedNoteRef', getters.selectedParentRef)
            # commit('historyPop')
        when 'l', "ArrowRight"
          console.log "right"
          if getters.selectedNote.children?
            commit("setSelectedNoteRef", getters.selectedChildren[0])
            # commit('moveRight')
          else # create new child note if none exist
            commit('setBusy', true)
            dispatch('createNote', {text:"", parent:state.selectedNoteRef})
            .then =>
              commit("setSelectedNoteRef", getters.selectedChildren[0])
              commit('setBusy', false)

    scrollToSelected: ({state}) ->
      if state.isLoading then return
      console.log "scroll to selected"
      element = document.getElementById("selectedNote")
      if not element? then return
      options = {
        centerIfNeeded: true
        duration: 300
        easing: 'easeInOut'
      }
      scrollIntoViewIfNeeded(element, options)

  getters:
    isBusy: (state) -> state.isBusy
    isLoading: (state) -> state.isLoading
    isConnected: (state) -> state.isConnected
    error : (state) -> state.error
    selectedNoteRef: (state, getters) -> state.selectedNoteRef
    selectedNote: (state, getters) -> getters.note(state.selectedNoteRef)
    selectedParentRef: (state, getters) -> getters.selectedNote?.parent
    selectedParent: (state, getters) -> getters.note(getters.selectedParentRef)
    dex: (state, getters) -> getters.selectedSiblings.indexOf(state.selectedNoteRef)
    selectedSiblings: (state, getters) ->
      # siblings = getters.note(state.selectedParentRef)?.children
      siblings = getters.selectedParent?.children
      siblings ?= []
      return siblings
    selectedElders: (state, getters) ->
      elders = getters.siblings(getters.selectedParent)
      elders ?= []
      return elders
    selectedChildren: (state, getters) ->
      children = getters.selectedNote?.children
      if getters.isLoading or not children?
        return []
      else
        return children
}
