<template lang="html">
  <div class="">
    <v-layout>
      <v-flex style="position:relative; top:0;" row sm-12>
        <v-card
        :class="{ selected: isSelected,
          'secondary': true,
          'elevation-19 ': isSelected,
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
        @blur="onBlur($event)"
        v-html="this.text">
        </v-card-text>

        <v-icon class="handle" v-show="active && !editMode">mdi-drag</v-icon>

        <v-btn fab dark small absolute depressed bottom left color="primary"
        v-show="isSelected && !keyboardMode && !editMode"
        class='elevation-19'
        @click.stop="startEdit()" >
          <v-icon>mdi-lead-pencil</v-icon>
        </v-btn>
        <v-btn fab dark small absolute depressed bottom left color="primary"
        v-show="isSelected && !keyboardMode && editMode"
        class='elevation-19'
        @click.stop="endEdit()" >
          <v-icon>check</v-icon>
        </v-btn>

        <v-btn color="error" small absolute flat fab ref="fab"
          style="top:0; right:0;"
          v-show="active && !editMode"
          @click.stop="showDeleteConfirm=!showDeleteConfirm" >
          <v-icon>mdi-delete-forever</v-icon>
        </v-btn>

        <v-tooltip left :activator="el" v-model="showDeleteConfirm"
          content-class="tooltip-opaque"
          color="primary" >
          <v-btn color="error" depressed small
          @click.stop="deleteNote(noteKey); showDeleteConfirm=false" >
            Delete
          </v-btn>
          <v-btn outline small @click.stop="showDeleteConfirm=false" >
            Cancel
          </v-btn>
        </v-tooltip>
      </v-card>
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
    showDeleteConfirm: false
    el: null
    # isSelected: false
  }

  computed: {
    ...mapGetters ['darkTheme', 'selectedNote', 'selectedParent', 'keyboardMode', 'editMode']
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
    ...mapActions ['setNoteText', 'deleteNote']
    onBlur: (e) ->
      console.log "blurred", e
      if e.relatedTarget?
        #blur from mouse, typically to another part of app
        this.endEdit()
      #blur from keyboard, typlically alt-tab, commit note text anyway, but don't end edit
      this.setNoteText {noteRef: this.noteKey, text: this.editor.getData()}

    onFocus: -> console.log "focused"

    onClick: ->
      this.$store.commit 'setSelectedNoteRef', this.noteKey
      this.$store.commit 'setKeyboardMode', false

    startEdit: ->
      console.log "startEdit"
      this.$store.commit 'setEditMode', true
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
      console.log "endEdit"
      this.$store.commit 'setEditMode', false
      this.setNoteText {noteRef: this.noteKey, text: this.editor.getData()}
      this.editor.destroy()

  }

  watch: {
    # text: -> this.editor.setData(this.text)
    # noteEditor: -> this.isSelected = this.noteEditor.isSelected
  }

  mounted: ->
    this.el = this.$refs.fab.$el

  destroyed: ->
    if this.editor?
      this.editor.destroy()
        .catch error ->
          console.log error
}
</script>

<style lang="css">
.tooltip-opaque {
  position:absolute; top:0; left: 0; opacity:1 !important;
}
/*drag handle*/
.handle {
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  z-index: 88;
  cursor: move;
}
/*remove weird bell shape on delete button*/
.card>:last-child {
    border-bottom-left-radius: 50%;
    border-bottom-right-radius: 50%;
}
/*hide editor toolbar*/
  .ck-balloon-panel {
    visibility: hidden ;
  }
  .card {
    /*background-color: #eef1f6;*/
    /*margin: 9px;*/
  }
  .card__text {
    padding-left: 25px;
    padding-bottom: 25px;
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
