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

export default {
  data: -> {
    numberOfCols: 3
    # selectedNoteIndexs: [0] #stack from beginning of array using unshift()/shift()
    editMode: false
    # selectedCol: 0
    # selectedNote: {}
  }
  # props: ['notes']
  components: {TextEditor}
# TODO: store helper function
  computed: {
    notes: -> this.$store.getters.notes
    isLoading: -> this.$store.getters.isLoading
    selectedElders: -> this.$store.getters.selectedElders
    selectedSiblings: -> this.$store.getters.selectedSiblings if not this.isLoading
    selectedChildren: -> this.$store.getters.selectedChildren
    selectedNote: -> this.$store.getters.selectedNote
    colSpan: -> 24 / this.numberOfCols
    cols: ->
      # root = this.$store.getters.notes
      if this.isLoading
        #Still loading notes from firebase
        # this.cols[0][0].isSelected = true
        # return [[[ {text: "Loading..."} ]],[],[]]
        return [[],[],[]]
      #  wrap note(data model) in noteEditor(view model)
      else
        # wrap = (note) -> {
        #   note
        #   isSelected: false
        # }
        # console.log root
        zero = this.$store.getters.refListToNotes(this.selectedElders)
        one = this.$store.getters.refListToNotes(this.selectedSiblings)
        two = this.$store.getters.refListToNotes(this.selectedChildren)
        # two = {}
        # selectedChildren = this.notes[this.$store.getters.selectedNote].children
        # if selectedChildren?
        #   for index, noteRef of selectedChildren
        #     do (noteRef) =>
        #       two[noteRef] = this.notes[noteRef]
      # two = one[this.selectedIndex[1]].children?
      # return [[{text:""}], [{text:""}], [{text:""}]]
        return [zero,one,two]
      }
  methods: {
    # onNoteClick: (i,j) ->
    #   this.selectedCol = i
    #   this.selectedNote = j

    keyboardMap: (e) ->
      console.log e.key, e.altKey
      # console.log this
      if this.editMode
        switch e.key
        # leave edit mode when done editing note
          when "Escape"
            console.log "Escape"
            selectedVue = this.$children[1].$children[this.$store.getters.dex[0]]
            selectedVue.editor.set('isReadOnly', true)
            selectedVue.editor.element.blur()
            this.$el.focus()
            this.editMode = false

      else if e.altKey
        this.$store.dispatch('shiftNote', e.key)
      else
        this.$store.dispatch('navigate', e.key)
        switch e.key
          # editing and deleting
          when "Enter"
            console.log "Enter"
            selectedVue = this.$children[1].$children[this.$store.getters.dex[0]]
            selectedVue.editor.set('isReadOnly', false)
            selectedVue.editor.element.focus()
            this.editMode = true
          when "Delete"
            console.log "Delete"
            noteToDelete = this.$store.getters.selectedNoteRef
            this.$store.dispatch('deleteNote', noteToDelete)



      # col = this.cols[this.selectedCol]
      # console.log this.selectedNote
      # switch e.key
      #   when "j"
      #     this.cols[this.selectedCol][this.selectedNote].isSelected = false
      #     this.selectedNote += 1
      #     this.cols[this.selectedCol][this.selectedNote].isSelected = true
      #   when "k"
      #     col[this.selectedNote].isSelected = false
      #     this.selectedNote -= 1
      #     col[this.selectedNote].isSelected = true
      #   when "h"
      #     this.selectedCol -= 1
      #   when "l"
      #     this.selectedCol += 1

      # col = this.cols[this.selectedCol]
      # i = this.selectedNote
      # if e.key == "j"
      #   # this.cols[selectedCol].length
      #   console.log this
      #   # col[i].isSelected = false
      #   # i += 1
      #   this.selectedNote += 1
      #   this.cols[this.selectedCol][this.selectedNote].isSelected = true
  }
  mounted: ->
    # keyboardMap: (e) ->
    #   console.log e.key
    #   # col = this.cols[this.selectedCol]
    #   # i = this.selectedNote
    #   if e.key == "j"
    #     # this.cols[selectedCol].length
    #     console.log this
    #     # col[i].isSelected = false
    #     # i += 1
    #     this.cols[this.selectedCol][this.selectedNote].isSelected = false
    #     this.selectedNote += 1
    #     this.cols[this.selectedCol][this.selectedNote].isSelected = true
    # console.log keyboardMap()
    # that = this
    # console.log this.keyboardMap
    # that = this
    # window.addEventListener("keyup", that.keyboardMap)
    this.$el.focus()
}
</script>

<style lang="css">
  .noteEditor-list {
    overflow-y: scroll;
    height: 100%;
  }
</style>
