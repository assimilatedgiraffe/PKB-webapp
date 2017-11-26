<template lang="html">
  <div class="">
    <el-card
      :class="{ selected: isSelected }">
      <div
        ref="editorDiv"
        @focus="onFocus"
        @blur="onBlur"
        :isReadOnly="isReadOnly">
      </div>
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
      this.noteKey == this.$store.getters.selectedNote
    # NoteDBkey: -> db.ref('notes').child(this.noteEditor.note['.key'])
    # isSelected: -> this.noteEditor.isSelected
  }

  props: {
    note: {type: Object, default: -> {text: ""}}
    isReadOnly: {default: true}
    noteKey: {default: ""}
  }

  methods: {
    onBlur: ->
      console.log "blurred"
      # this.isSelected = false
      # this.noteDBkey.child('text').set(this.editor.getData())
    onFocus: ->
      console.log "focused"
      # this.isReadOnly = false
      # this.isSelected = true
  }

  watch: {
    text: -> this.editor.setData(this.text)
    # noteEditor: -> this.isSelected = this.noteEditor.isSelected
  }

  mounted: ->
    initEditor = (returnedEditor) =>
      this.editor = returnedEditor
      this.editor.setData(this.note.text)
      this.editor.set('isReadOnly', this.isReadOnly)

      # TODO: remove toolbar
    InlineEditor.create(this.$refs.editorDiv, { toolbar: [] })
    .then(initEditor)
    .catch((error) -> console.error(error))

}
</script>

<style lang="css">
  .selected {
    border: 7px solid blue;
  }
</style>
