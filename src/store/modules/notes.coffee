import Vue from 'vue'

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
    addLocalNote: (state, payload) -> Vue.set(state.notes, payload.id, payload.data)
    modifyLocalNote: (state, payload) ->  Vue.set(state.notes, payload.id, payload.data)
    removeLocalNote: (state, payload) -> delete state.notes[payload]

  getters:
    notes: (state) -> state.notes
    note: (state) -> (ref) -> state.notes[ref]
    rootNode: (state, getters) -> getters.note('rootNode')
    siblings: (state) -> (note) -> state.notes[note?.parent]?.children
    siblingsByRef: (state, getters) -> (ref) -> state.notes[getters.note(ref)?.parent]?.children
    # return dict of {ref: note object} from list of refs
    refListToNotes: (state) -> (refs) ->
      return {} if !refs
      notes = {}
      for noteRef in refs
        do (noteRef) =>
          notes[noteRef] = state.notes[noteRef] if state.notes[noteRef]?
      return notes
}
