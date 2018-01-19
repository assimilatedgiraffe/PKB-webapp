<template lang="html">
  <div id="main-app">
    <el-dialog
      title="Login"
      :visible="loginVisible">
      <Login></Login>
    </el-dialog>
    <el-row>
      <el-col :span="24">
        <el-menu mode="horizontal">
          <el-menu-item @click="logOut" index="1"> Logout </el-menu-item>
        </el-menu>
      </el-col>
    </el-row>
    <el-row class="header">
      <el-col :span="24">
        history/breadcrumbs for subjects; recents
        <NoteList :notes="notes" is-horizontal="true"></NoteList>
      </el-col>
    </el-row>
    <el-row class="main-section">
      <el-col :span="24">
        grid view
        <NoteGrid :notes="notes"></NoteGrid>
      </el-col>
    </el-row>
  </div>
</template>


<script lang="coffee">

# import { db } from '../firebase.js'
import TextEditor from './TextEditor.vue'
import NoteList from './NoteList.vue'
import NoteGrid from './NoteGrid.vue'
import Login from './Login.vue'

import testAuth from './testAuth'
import firebase from 'firebase'

export default {
  name: 'MainApp'

  # data: ->

  computed:
    loginVisible: -> not this.$store.getters.user?
    notes: ->

  # firebase: {
  #     # notes: { source: db.ref('notes') }
  #   }

  components: { NoteList, NoteGrid, Login }

  methods:
    logOut: ->
      console.log "logOut"
      firebase.auth().signOut()

  created: ->
    # this.$store.dispatch('signIn', testAuth)
    # this.$store.dispatch('loadDatabase')
    # this.$store.dispatch('watchDatabase')
    firebase.auth().onAuthStateChanged((user) =>
      if user
        this.$store.dispatch('signIn', user)
      else
        this.$store.dispatch('signOut')
    )

  mounted: ->
    # this.$store.dispatch('generateTestData')
}
</script>


<style lang="css">
.el-col {
  height: 100%;
}
.header {
  height: 20vh;
}
.main-section {
  height: 80vh;
}

/*wireframe css*/
.el-col {
  border-style: solid;
}

</style>
