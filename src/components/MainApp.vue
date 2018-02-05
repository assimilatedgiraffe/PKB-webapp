<template lang="html">
  <!-- <div id="main-app"> -->
  <v-container @click.native="setFocus">
        <!-- grid view -->
        <NoteGrid ref="NoteGrid"></NoteGrid>
  </v-container>
</template>


<script lang="coffee">

import TextEditor from './TextEditor.vue'
import NoteList from './NoteList.vue'
import NoteGrid from './NoteGrid.vue'
import Login from './Login.vue'
import { mapGetters } from 'vuex'

import firebase from 'firebase'

export default {
  name: 'MainApp'

  # data: ->

  computed: {
    ...mapGetters ['isLoading', 'isBusy', 'error']
    # loginVisible: -> not this.$store.getters.user?
    isDisconnected: -> not this.$store.getters.isConnected
    # notes: ->
  }

  components: { NoteList, NoteGrid, Login }

  methods:
    setFocus: (e) ->
      console.log "setFocus", e
      return if e.path.length > 13
      this.$refs.NoteGrid.$el.focus()

  watch:
    error: (newError) ->
      if newError != ""
        this.$message.error(newError)
        this.$store.commit 'setError', ""

    isLoading: (newValue) ->
      if newValue == false
        this.$refs.NoteGrid.$el.focus()


  created: ->
    # this.$store.dispatch('loadDatabase')
    # this.$store.dispatch('watchDatabase')
    firebase.auth().onAuthStateChanged((user) =>
      if user
        this.$store.dispatch('signIn', user)
      else
        this.$store.dispatch('signOut')
    )
    # document.addEventListener('click', this.documentClick)

  mounted: ->
    # this.$store.dispatch('generateTestData')

  destroyed: ->
    # document.removeEventListener('click', this.documentClick)
}
</script>


<style lang="css">
.el-col {
  /*height: 100%;*/
}
.header {
  background-color: #eef1f6;
  /*margin-bottom: 10px;*/
}
.main-section {
  /*height: 80vh;*/
}
.el-menu {
  float: right;
}
.title {
  padding-left: 10px;
  margin: auto;
}

.el-container {
  height: 100vh;
}
.el-header {
  padding: 0;
}
body {
  background-color: lightgrey;
  margin: 0;
}
.el-main {
  overflow-y: hidden;
}
/*wireframe css*/
/*.el-col {
  border-style: solid;
}*/

</style>
