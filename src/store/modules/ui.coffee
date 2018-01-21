export default {
  state:
    isLoading: true
    selectedNote: {}

  mutations:
    setLoading: (state, payload) -> state.isLoading = payload
    setSelectedNote: (state, payload) -> state.selectedNote = payload

  actions:
    loadUI: ({commit, state, getters}) ->
      commit("setSelectedNote", getters.rootNode.children[0])
      commit("setLoading", false)

  getters:
    isLoading: (state) -> state.isLoading
    selectedNote: (state) -> state.selectedNote



}
