<template lang="html">
  <div class="">
      <v-layout>
        <v-flex row sm-12>
          <!-- <v-tooltip
          @mouseenter="active=true"
          @mouseleave="active=false"
          color="transparent"
          debounce="3000"
          close-delay="1200"
          transtition="zoom-transition"
          nudge-up="500"
          min-width="200"
          left> -->
          <v-icon class="handle">mdi-drag</v-icon>
    <v-card
      :class="{ selected: isSelected,
      'secondary': true,
      'elevation-15 ': isSelected,
      'elevation-4 ': isSelectedParent,
      selectedParent: isSelectedParent}"
      ref="card"
      :id="this.id"
      hover
      @mouseenter="active=true"
      @mouseleave="active=false"
      @click.native="onClick"
      slot="activator"
      >
        <v-card-text
        ref="editorDiv"
        @focus="onFocus"
        @blur="onBlur"
        v-html="this.text">
        </v-card-text>
        <v-card-actions v-show="false">
          <v-divider></v-divider>
          <v-btn
          fab
          dark
          flat
          small
          color="green"
          v-show="active"
          >
          <v-icon>edit</v-icon>
        </v-btn>
      <v-btn
        fab
        dark
        flat
        small
        v-show="active"
      >
        <v-icon>edit</v-icon>
      </v-btn>
    </v-card-actions>
    <v-btn
      fab
      dark
      small
      flat
      absolute
      bottom left
      color="primary"
      v-show="active"
    >
      <v-icon>edit</v-icon>
    </v-btn>
          <v-btn
          color="red darken-4"
          small
          absolute
          flat
          top right
          fab
          v-show="active"
          >
          <v-icon>mdi-delete-forever</v-icon>
          <v-icon>close</v-icon>
        </v-btn>
      </v-card>
    <!-- </v-tooltip> -->
      </v-flex>
    </v-layout>

</div>
</template>

<script lang="coffee">
import InlineEditor from '@ckeditor/ckeditor5-build-inline'
# import {db} from '../firebase'
import { mapGetters } from 'vuex'
import { mapActions } from 'vuex'

export default {
  data: -> {
    editor: {}
    active: false
    fab: false
    # isSelected: false
  }

  computed: {
    ...mapGetters ['darkTheme', 'selectedNote', 'selectedParent']
    # note: -> this.noteEditor.note
    text: -> this.note.text
    isSelected: ->
      # console.log this.noteKey
      # console.log this.$store.getters.selectedNote
      this.note == this.selectedNote
    # NoteDBkey: -> db.ref('notes').child(this.noteEditor.note['.key'])
    # isSelected: -> this.noteEditor.isSelected
    isSelectedParent: -> this.note == this.selectedParent
    id: -> if this.isSelected then "selectedNote" else ""
  }

  props: {
    note: {type: Object, default: -> {text: ""}}
    noteKey: {default: ""}
  }

  methods: {
    ...mapActions ['setNoteText']
    onBlur: ->
      console.log "blurred"
      # this.isSelected = false
      this.setNoteText {noteRef: this.noteKey, text: this.editor.getData()}
    onFocus: ->
      console.log "focused"
      # this.isReadOnly = false
      # this.isSelected = true
    onClick: ->
      this.$store.commit 'setSelectedNoteRef', this.noteKey
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
    endEdit: ->
      this.setNoteText {noteRef: this.noteKey, text: this.editor.getData()}
      this.editor.destroy()

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
  .card {
    /*background-color: #eef1f6;*/
    /*margin: 9px;*/
  }
  .selected .card__text {
    /*padding: 16px;*/
    /*border: 4px solid #48a3f5;*/
    /*background-color: #fff;*/
    /*margin: 0;*/
  }
  .selectedParent .card__text {
    /*padding: 17px;*/
    /*border: 3px solid #8cbfec;*/
    /*background-color: #f8f8ff;*/
    /*margin: 0;*/
  }
</style>
