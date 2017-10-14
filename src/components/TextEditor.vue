<template lang="html">
  <div class="">
    <div ref="editorDiv" @blur="onBlur" :isReadOnly="isReadOnly"></div>
    <!-- <el-input v-model="text" placeholder="this is the main text input"></el-input> -->
    <!-- <textarea name="name" rows="8" cols="80">test</textarea> -->
  </div>
</template>

<script lang="coffee">
import InlineEditor from '@ckeditor/ckeditor5-build-inline'
import {db} from '../firebase'

export default {
  data: -> {
    editor: {}
  }

  computed: {
    text: -> this.note.text
    NoteDBkey: -> db.ref('notes').child(this.note['.key'])
  }

  props: {
    note: {type: Object, default: -> {text: ""}}
    isReadOnly: {default: false}
  }

  methods: {
    onBlur: -> this.noteDBkey.child('text').set(this.editor.getData())
  }

  watch: {
    text: -> this.editor.setData(this.text)
  }

  mounted: ->
    initEditor = (returnedEditor) =>
      this.editor = returnedEditor
      this.editor.setData(this.note.text)
      this.editor.set('isReadOnly', this.isReadOnly)

    InlineEditor.create(this.$refs.editorDiv, { toolbar: [] }) # TODO: remove toolbar
    .then(initEditor)
    .catch((error) -> console.error(error))

}
</script>

<style lang="css">
</style>
