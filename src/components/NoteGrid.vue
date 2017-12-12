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
    selectedNoteIndexs: [0] #stack from beginning of array using unshift()/shift()
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
    # keymap: (e) ->
    #   console.log e.key
    #   console.log this
    #   if this.editMode
    #     {
    #     'esc': =>
    #       console.log "esc"
    #       selectedVue = this.$children[1].$children[this.selectedNoteIndexs[0]]
    #       selectedVue.editor.set('isReadOnly', true)
    #       selectedVue.editor.element.blur()
    #       this.editMode = false
    #
    #     }
    #   else
    #     {
    #     'j': =>
    #       console.log "down"
    #       if this.selectedSiblings.length > this.selectedNoteIndexs[0] + 1
    #         this.selectedNoteIndexs[0] += 1
    #         this.$store.commit('setSelectedNote', this.selectedSiblings[this.selectedNoteIndexs[0]])
    #     'k': =>
    #       console.log "up"
    #       if this.selectedNoteIndexs[0] > 0
    #         this.selectedNoteIndexs[0] -= 1
    #         this.$store.commit('setSelectedNote', this.selectedSiblings[this.selectedNoteIndexs[0]])
    #     'h': =>
    #       console.log "left"
    #       selectedParent = this.notes[this.$store.getters.selectedNote].parent
    #       this.selectedNoteIndexs.shift()
    #       this.$store.commit('setSelectedNote', selectedParent)
    #     'l': =>
    #       console.log "right"
    #       selectedChildren = this.notes[this.$store.getters.selectedNote].children
    #       this.selectedNoteIndexs.unshift(0)
    #       this.$store.commit('setSelectedNote', Object.values(selectedChildren)[0])
    #     'enter': =>
    #       console.log "enter"
    #       selectedVue = this.$children[1].$children[this.selectedNoteIndexs[0]]
    #       selectedVue.editor.set('isReadOnly', false)
    #       selectedVue.editor.element.focus()
    #       this.editMode = true
    #       # this.$el.blur()
    # }
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
            selectedVue = this.$children[1].$children[this.selectedNoteIndexs[0]]
            selectedVue.editor.set('isReadOnly', true)
            selectedVue.editor.element.blur()
            this.$el.focus()
            this.editMode = false

      else if e.altKey
        siblings = this.selectedSiblings
        dex = this.selectedNoteIndexs[0]
        switch e.key
        # move selected note
          when 'j'
            console.log "move down"
            if siblings.length > dex + 1
              siblings.splice(dex + 1, 0, siblings.splice(dex, 1)[0])
              this.$store.dispatch('setNoteChildren', {
                noteRef: this.notes[this.selectedNote].parent
                children: siblings
                }).then =>
                  this.selectedNoteIndexs[0] += 1
          when 'k'
            console.log "move up"
            if dex > 0
              siblings.splice(dex - 1, 0, siblings.splice(dex, 1)[0])
              this.$store.dispatch('setNoteChildren', {
                noteRef: this.notes[this.selectedNote].parent
                children: siblings
                }).then =>
                  this.selectedNoteIndexs[0] -= 1
      else
        switch e.key
        # vim style navigaion
          when "j"
            # TODO - crash when creating more than one new note at a time (multiple presses at end of list)
            console.log "down"
            if this.selectedSiblings.length > this.selectedNoteIndexs[0] + 1
              this.selectedNoteIndexs[0] += 1
              this.$store.commit('setSelectedNote', this.selectedSiblings[this.selectedNoteIndexs[0]])
            else #create new empty note if none exists
              selectedParent = this.notes[this.$store.getters.selectedNote].parent
              this.$store.dispatch('createNote', {text:"", parent:selectedParent})
                .then =>
                  this.selectedNoteIndexs[0] += 1
                  this.$store.commit('setSelectedNote', this.selectedSiblings[this.selectedNoteIndexs[0]])
          when 'k'
            console.log "up"
            if this.selectedNoteIndexs[0] > 0
              this.selectedNoteIndexs[0] -= 1
              this.$store.commit('setSelectedNote', this.selectedSiblings[this.selectedNoteIndexs[0]])
          when 'h'
            console.log "left"
            selectedParent = this.notes[this.$store.getters.selectedNote].parent
            if selectedParent != "rootNode"
              this.selectedNoteIndexs.shift()
              this.$store.commit('setSelectedNote', selectedParent)
          when 'l'
            console.log "right"
            #TODO: breaks on multiple quick presses
            selectedChildren = this.notes[this.$store.getters.selectedNote].children
            if selectedChildren?
              this.selectedNoteIndexs.unshift(0)
              this.$store.commit('setSelectedNote', Object.values(selectedChildren)[0])
            else # create new child note if none exist
              this.$store.dispatch('createNote', {text:"", parent:this.$store.getters.selectedNote})
                .then =>
                  selectedChildren = this.notes[this.$store.getters.selectedNote].children
                  this.selectedNoteIndexs.unshift(0)
                  this.$store.commit('setSelectedNote', Object.values(selectedChildren)[0])

          # editing and deleting
          when "Enter"
            console.log "Enter"
            selectedVue = this.$children[1].$children[this.selectedNoteIndexs[0]]
            selectedVue.editor.set('isReadOnly', false)
            selectedVue.editor.element.focus()
            this.editMode = true
          when "Delete"
            console.log "Delete"
            noteToDelete = this.$store.getters.selectedNote
            if this.selectedNoteIndexs[0] > 0
              this.selectedNoteIndexs[0] -= 1
              this.$store.commit('setSelectedNote', this.selectedSiblings[this.selectedNoteIndexs[0]])
              this.$store.dispatch('deleteNote', noteToDelete)
            else
              selectedParent = this.notes[this.$store.getters.selectedNote].parent
              if selectedParent != "rootNode"
                this.selectedNoteIndexs.shift()
                this.$store.commit('setSelectedNote', selectedParent)
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
