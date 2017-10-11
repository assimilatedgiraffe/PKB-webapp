<template lang="html">
  <div class="">
    <div ref="editorDiv" @blur="onBlur" :isReadOnly="isReadOnly"></div>
    <!-- <el-input v-model="text" placeholder="this is the main text input"></el-input> -->
    <!-- <textarea name="name" rows="8" cols="80">test</textarea> -->
  </div>
</template>

<script>
import InlineEditor from '@ckeditor/ckeditor5-build-inline'

export default {
  data () {
    return {
      editor: {}
    }
  },

  computed: {
    text: function () { return this.note.text }
  },

  props: {
    note: {type: Object, default: () => { return {text: ''} }},
    isReadOnly: {default: false}
  },

  methods: {
    onBlur () {
      this.note.text = this.editor.getData()
    }
  },

  watch: {
    text: function () { this.editor.setData(this.text) }
  },

  mounted () {
    InlineEditor.create(this.$refs.editorDiv, {
      toolbar: [] // TODO: remove toolbar
    }).then(returnedEditor => {
      this.editor = returnedEditor
      this.editor.setData(this.note.text)
      this.editor.set('isReadOnly', this.isReadOnly)
    }).catch(error => {
      console.error(error)
    })
  }

}
</script>

<style lang="css">
</style>
