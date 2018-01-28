<template lang="html">
  <div class="">
    <el-card
      :class="{ selected: isSelected, selectedParent: isSelectedParent}"
      ref="card"
      :id="this.id" >
      <div
        ref="editorDiv"
        @focus="onFocus"
        @blur="onBlur"
        v-html="this.text"></div>
    </el-card>
  </div>
</template>

<script lang="coffee">
import InlineEditor from '@ckeditor/ckeditor5-build-inline'
# import {db} from '../firebase'

export default {
  data: -> {
    editor: {}
    # isSelected: false
  }

  computed: {
    # note: -> this.noteEditor.note
    text: -> this.note.text
    isSelected: ->
      # console.log this.noteKey
      # console.log this.$store.getters.selectedNote
      this.note == this.$store.getters.selectedNote
    # NoteDBkey: -> db.ref('notes').child(this.noteEditor.note['.key'])
    # isSelected: -> this.noteEditor.isSelected
    isSelectedParent: -> this.note == this.$store.getters.selectedParent
    id: -> if this.isSelected then "selectedNote" else ""
  }

  props: {
    note: {type: Object, default: -> {text: ""}}
    noteKey: {default: ""}
  }

  methods: {
    onBlur: ->
      console.log "blurred"
      # this.isSelected = false
      this.$store.dispatch('setNoteText', {
        noteRef: this.noteKey
        text: this.editor.getData()
        })
      this.editor.destroy()
    onFocus: ->
      console.log "focused"
      # this.isReadOnly = false
      # this.isSelected = true
    startEdit: ->
      initEditor = (returnedEditor) =>
        this.editor = returnedEditor
        # this.editor.setData(this.note.text)
        # this.editor.set('isReadOnly', this.isReadOnly)
        this.editor.element.focus()

        # TODO: remove toolbar
      InlineEditor.create(this.$refs.editorDiv, { toolbar: [] })
      .then(initEditor)
      .catch((error) -> console.error(error))

  }

  watch: {
    # text: -> this.editor.setData(this.text)
    # noteEditor: -> this.isSelected = this.noteEditor.isSelected
  }

  # mounted: ->

  destroyed: ->
    if this.editor?
      this.editor.destroy()
        .catch error ->
          console.log error
}
</script>

<style lang="css">
  .el-card {
    /*background-color: #eef1f6;*/
    /*margin: 2px;*/
  }
  .selected .el-card__body {
    padding: 16px;
    border: 4px solid #48a3f5;
    /*background-color: #fff;*/
    /*margin: 0;*/
  }
  .selectedParent .el-card__body {
    padding: 17px;
    border: 3px solid #8cbfec;
    /*background-color: #f8f8ff;*/
    /*margin: 0;*/
  }
</style>
