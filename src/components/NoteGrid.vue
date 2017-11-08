<template lang="html">
  <div v-hotkey="keymap" >
    <el-col  :span="colSpan" v-for="(col, i) in cols" :key="col.id" @keyup="keyboardMap"  >
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
    selectedNoteIndex: 0
    # selectedCol: 0
    # selectedNote: {}
  }
  # props: ['notes']
  components: {TextEditor}
  computed: {
    notes: -> this.$store.getters.notes
    isLoading: -> this.$store.getters.isLoading
    selectedSiblings: -> this.$store.getters.selectedSiblings if not this.isLoading
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
        zero = this.notes# root.children.map wrap
      # one = zero[this.selectedIndex[0]].children?
      # two = one[this.selectedIndex[1]].children?
      # return [[{text:""}], [{text:""}], [{text:""}]]
        return [zero,zero,zero]
    keymap: ->
      {
      'j': =>
        console.log "down"
        if this.selectedSiblings.length > this.selectedNoteIndex + 1
          this.selectedNoteIndex += 1
          this.$store.commit('setSelectedNote', this.selectedSiblings[this.selectedNoteIndex])
      'k': =>
        console.log "up"
        if this.selectedNoteIndex > 0
          this.selectedNoteIndex -= 1
          this.$store.commit('setSelectedNote', this.selectedSiblings[this.selectedNoteIndex])
      'h': =>
        console.log "left"
      'l': =>
        console.log "right"
    }
  }
  methods: {
    # onNoteClick: (i,j) ->
    #   this.selectedCol = i
    #   this.selectedNote = j

    keyboardMap: (e) ->
      # console.log e.key
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
    that = this
    window.addEventListener("keyup", that.keyboardMap)
}
</script>

<style lang="css">
  .noteEditor-list {
    overflow-y: scroll;
    height: 100%;
  }
</style>
