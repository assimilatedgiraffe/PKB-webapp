<template lang="html">
  <div tabindex="0" @keyup="keyboardMap">
    <el-col  :span="colSpan" v-for="(col, i) in cols" :key="col.id" >
      <div class="note-list" >
          <div v-for="(note,key) in col"
            :key="note.id">
            <TextEditor
              :note="note"
              :noteKey="key">
              <!-- @click.native="onNoteClick(i,j)"> -->
            </TextEditor>
          </div>
      </div>
    </el-col>
  </div>
</template>

<script lang="coffee">
import TextEditor from './TextEditor.vue'
import { mapGetters } from 'vuex'

export default {
  data: -> {
    numberOfCols: 3
    editMode: false
  }

  components: {TextEditor}
# TODO: store helper function
  computed: {
    ...mapGetters([
      'notes', 'isBusy', 'isLoading', 'isConnected',
      'selectedElders', 'selectedSiblings', 'selectedChildren', 'selectedNote'
      ])
    colSpan: -> 24 / this.numberOfCols
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
            selectedVue.editor.set('isReadOnly', true)
            selectedVue.editor.element.blur()
            this.$el.focus()
            this.editMode = false

      else if e.altKey
        this.$store.dispatch('shiftNote', e.key)
      else
        this.$store.dispatch('navigate', e.key)
        return if not this.isConnected
        switch e.key
          # editing and deleting
          when "Enter"
            console.log "Enter"
            selectedVue = this.$children[1].$children[this.$store.getters.dex]
            selectedVue.editor.set('isReadOnly', false)
            selectedVue.editor.element.focus()
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

<style lang="css">
  .noteEditor-list {
    /*overflow-y: scroll;*/
    /*height: 100%;*/
  }
</style>
