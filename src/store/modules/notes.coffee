export default {
  state:
    notes: {}
    ###
    text: ''
    parent: ref
    children: [...refs]
    ###

  mutations:
    setNotes: (state, payload) -> state.notes = payload

  getters:
    notes: (state) -> state.notes
    note: (state) -> (ref) -> state.notes[ref]
    rootNode: (state, getters) -> getters.note('rootNode')
    siblings: (state) -> (note) -> state.notes[note?.parent]?.children
    # return dict of {ref: note object} from list of refs
    refListToNotes: (state) -> (refs) ->
      return {} if !refs
      notes = {}
      for noteRef in refs
        do (noteRef) =>
          notes[noteRef] = state.notes[noteRef]
      return notes
        # get elders of currently selected note
    # selectedElders: (state, getters) ->
    #   if getters.isLoading
    #     return []
    #   else
    #     parentRef = getters.selectedNote.parent
    #     if parentRef == "rootNode"
    #       return []
    #     else
    #       grandParentRef = state.notes[parentRef].parent
    #       return state.notes[grandParentRef].children
    # get siblings of currently selected note
    # selectedSiblings: (state, getters) ->
    #   if (not getters.isLoading) and getters.selectedNote?
    #     parent = getters.selectedNote.parent
    #     siblings = {}
    #     # for noteRef in
    #     #   do (noteRef) =>
    #     #     siblings[noteRef] = state.notes[noteRef]
    #     return state.notes[parent].children
    # get children of currently selected note
    # selectedChildren: (state, getters) ->
    #   children = getters.selectedNote?.children
    #   if getters.isLoading or not children?
    #     return []
    #   else
    #     return children
    # rootNode: (state) -> state.rootNode
}
