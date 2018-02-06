<template lang="html">
  <div tabindex="0" @keyup="keyboardMap">
    <v-container fluid >
    <v-layout row justify-start align-start fill-height align-content-start>
      <v-flex xs4 v-for="(col, i) in cols" :key="col.id" >
        <!-- <div class="note-list" > -->
        <!-- <v-container grid-list-lg> -->
          <!-- <v-layout row wrap> -->
          <v-container grid-list-xl>
          <v-flex column >
          <draggable :list="Object.keys(col)" :options="{group:'notes'}" @change="onDrag($event, i)">
          <div v-for="(note,key) in col"
            :key="note.id">
            <TextEditor
              :note="note"
              :noteKey="key">
              <!-- @click.native="onNoteClick(i,j)"> -->
            </TextEditor>
          </div>
        </draggable>
        <v-flex class="text-xs-center">
      <v-btn
        dark
        block
        flat
        color="primary"
      >
        <v-icon>add</v-icon>
      </v-btn>
    </v-flex>
    </v-flex>
  </v-container>
        <!-- </v-layout> -->
        <!-- </v-container> -->
      </v-flex>
    </v-layout>
  </v-container>
  </div>
</template>

<script lang="coffee">
import TextEditor from './TextEditor.vue'
import { mapGetters } from 'vuex'
import draggable from 'vuedraggable'

export default {
  data: -> {
    numberOfCols: 3
    editMode: false
    list: [1,2,3,4]
  }

  components: {TextEditor, draggable}
# TODO: store helper function
  computed: {
    ...mapGetters([
      'notes', 'isBusy', 'isLoading', 'isConnected', 'siblings'
      'selectedElders', 'selectedSiblings', 'selectedChildren', 'selectedNote'
      ])
    colSpan: -> 24 / this.numberOfCols
    col1:
      get: -> this.selectedSiblings
      set: (value) -> return
    cols: ->
      if this.isLoading
        #Still loading notes from firebase
        return [[],[],[]]
      else
        zero = this.$store.getters.refListToNotes(this.selectedElders)
        one = this.$store.getters.refListToNotes(this.selectedSiblings)
        two = this.$store.getters.refListToNotes(this.selectedChildren)
        return [zero,one,two]
  }
  methods: {
    # onNoteClick: (i,j) ->
    #   this.selectedCol = i
    #   this.selectedNote = j
    onDrag: (evt, col) ->
      console.log evt, col
      if evt.moved
        console.log "dragMove"
        note = this.notes[evt.moved.element]
        siblings = this.siblings(note)
        spliced = siblings.splice(evt.moved.oldIndex, 1)[0]
        siblings.splice(evt.moved.newIndex, 0, spliced)
        this.$store.dispatch 'setNoteChildren', { noteRef: note.parent, children: siblings }

      else if evt.added
        console.log "dragAdded"
        parent = this.cols[col][Object.keys(this.cols[col])[0]].parent
        console.log parent
        this.$store.dispatch 'setNoteParent', {
          noteRef: evt.added.element
          parentRef: parent
          index: evt.added.newIndex}

    keyboardMap: (e) ->
      if this.isBusy then return
      console.log e.key, e.altKey
      # console.log this
      if this.editMode
        switch e.key
        # leave edit mode when done editing note
          when "Escape"
            console.log "Escape"
            selectedVue = this.$children[1].$children[this.$store.getters.dex]
            # selectedVue.editor.element.blur()
            selectedVue.endEdit()
            this.$el.focus()
            this.editMode = false

      else if e.altKey
        if e.key != "Alt"
          this.$store.dispatch('shiftNote', e.key)
      else
        this.$store.dispatch('navigate', e.key)
        switch e.key
          # editing and deleting
          when "Enter", "i", "a"
            console.log "Enter"
            selectedVue = this.$children[1].$children[this.$store.getters.dex]
            # selectedVue.editor.element.focus()
            selectedVue.startEdit()
            this.editMode = true
          when "Delete"
            console.log "Delete"
            noteToDelete = this.$store.getters.selectedNoteRef
            this.$store.dispatch('deleteNote', {noteRef:noteToDelete, j:0})

  }

  watch:
    selectedNote: (newId, oldId)->
      console.log newId, oldId
      # if newId == "selectedNote"
      setTimeout (=> this.$store.dispatch('scrollToSelected')) , 20

  mounted: ->
    this.$el.focus()
}
</script>

<style scoped lang="css">
.grid-list-xl {
  padding: 9px;
}
</style>
